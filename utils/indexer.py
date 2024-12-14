import os
import glob
import json
import PyPDF2
import chardet
import logging
from typing import List
from dotenv import load_dotenv
from google.cloud import firestore
from google.cloud import aiplatform
from vertexai.preview.language_models import TextEmbeddingModel

base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
env_path = os.path.join(base_dir, '.env')
load_dotenv(dotenv_path=env_path)

logging.basicConfig(
    level=logging.INFO, 
    format='%(asctime)s - %(levelname)s: %(message)s'
)
logger = logging.getLogger(__name__)

REGION = os.getenv('REGION')
PROJECT_ID = os.getenv('PROJECT_ID')
BUCKET_NAME = os.getenv('BUCKET_NAME')
FIREBASE_ID = os.getenv('FIREBASE_ID')

if not PROJECT_ID or not REGION:
    raise ValueError("PROJECT_ID and REGION must be set in the .env file")

def preprocess(text: str) -> str:
    text = ' '.join(text.split())    
    return text

def detect_encoding(file_path):
    with open(file_path, 'rb') as file:
        raw_data = file.read()
        result = chardet.detect(raw_data)
    return result['encoding'] or 'utf-8'

def extract_text_from_pdf(pdf_path):
    try:
        with open(pdf_path, 'rb') as file:
            pdf_reader = PyPDF2.PdfReader(file)
            text = ""
            for page in pdf_reader.pages:
                text += page.extract_text() + "\n"
            return text
    except Exception as e:
        logger.error(f"Error extracting text from PDF {pdf_path}: {e}")
        return ""

def chunk(
    document_path: str, 
    max_chunk_size: int = 4000, 
    overlap: int = 500
) -> List[str]: 
    try:
        file_ext = os.path.splitext(document_path)[1].lower()
        if file_ext == '.pdf':
            text = extract_text_from_pdf(document_path)
        else:
            encoding = detect_encoding(document_path)
            logger.info(f"Detected encoding for {document_path}: {encoding}")
            with open(document_path, 'r', encoding=encoding) as f:
                text = f.read()
        text = preprocess(text)
        chunks = []
        start = 0
        while start < len(text):
            chunk = text[start:start + max_chunk_size]
            chunks.append(chunk)
            start += max_chunk_size - overlap
        return chunks
    except Exception as e:
        logger.error(f"Error processing {document_path}: {e}")
        return []
    
def store_chunk_in_firestore(chunk, metadata, collection_name='philippines'):
    try:
        doc_ref = db.collection(collection_name).document()
        doc_ref.set({
            'chunk': chunk,
            'chunk_index': metadata['chunk_index'],
            'chunk_length': metadata['chunk_length'],
            'embedding_index': metadata['embedding_index'],
        })
        logger.info(f"Stored chunk {metadata['chunk_index']} in Firestore.")
    except Exception as e:
        logger.error(f"Error storing chunk in Firestore: {e}")


def generate_embeddings(
    documents: List[str], 
    batch_size: int = 8,
    model: str = "textembedding-gecko@003"
):
    embedding_model = TextEmbeddingModel.from_pretrained(model)   
    all_embeddings = []
    document_metadata = []
    for i in range(0, len(documents), batch_size):
        batch_docs = documents[i:i+batch_size]
        try:
            batch_embeddings = embedding_model.get_embeddings(batch_docs)
            for idx, (chunk, embedding) in enumerate(zip(batch_docs, batch_embeddings)):
                all_embeddings.append(embedding.values)
                document_metadata.append({
                    'chunk_index': i + idx,
                    'chunk_length': len(chunk),
                    'embedding_index': len(all_embeddings) - 1
                })
            
            logger.info(f"Processed batch {i//batch_size + 1}...")
        except Exception as e:
            logger.error(f"Error could not process embedding batch {i//batch_size + 1}: {e}")
    
    return all_embeddings, document_metadata

def create_index(
    local_directory: str,
    project_id: str = PROJECT_ID,
    region: str = REGION,
    bucket_name: str = BUCKET_NAME,
    index_name: str = "themis-philippines"
):
    os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = "./themis-444320-2f62ab86cb53.json"
    aiplatform.init(project=project_id, location=region)
    legal_docs = glob.glob(os.path.join(local_directory, '*.pdf'))
    if not legal_docs:
        logger.error(f"No documents found in {local_directory}.")
        return None
    all_document_chunks = []
    for doc_path in legal_docs:
        logger.info(f"Processing document {os.path.basename(doc_path)}...")
        chunks = chunk(doc_path)
        all_document_chunks.extend(chunks)
    embeddings, doc_metadata = generate_embeddings(
        documents=all_document_chunks,
        batch_size=8
    )
    for c, metadata in zip(all_document_chunks, doc_metadata):
        store_chunk_in_firestore(c, metadata)
    index = aiplatform.MatchingEngineIndex.create_tree_ah_index(
        display_name=index_name,
        contents_delta_uri=f"gs://{bucket_name}",
        dimensions=len(embeddings[0]),
        approximate_neighbors_count=100,
        distance_measure_type="SQUARED_L2_DISTANCE"
    )
    logger.info(f"Vector Search Index created: {index.name}")
    return {
        'total_chunks': len(all_document_chunks),
        'embedding_count': len(embeddings),
        'index_name': index.name,
        'document_metadata': doc_metadata
    }

if __name__ == "__main__":   
    db = firestore.Client(project=FIREBASE_ID) 
    LEGAL_DOCUMENTS_DIR = "../downloads"
    rag_metadata = create_index(
        local_directory=LEGAL_DOCUMENTS_DIR,
    )
    if rag_metadata:
        print(json.dumps(rag_metadata, indent=2))
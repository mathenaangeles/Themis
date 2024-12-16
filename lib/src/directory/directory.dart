import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:themis/src/directory/directory_controller.dart';

class Directory extends StatefulWidget {
  const Directory({super.key});

  @override
  _DirectoryState createState() => _DirectoryState();
}

class _DirectoryState extends State<Directory> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = [
    'Criminal Law',
    'Civil Law',
    'Commercial Law',
    'Remedial Law',
    'Taxation Law',
    'International Law',
    'Environmental Law',
  ];
  final Set<String> _selectedFilters = {};

  @override
  void initState() {
    super.initState();
    final directoryController =
        Provider.of<DirectoryController>(context, listen: false);
    directoryController.fetchLawyers();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    Provider.of<DirectoryController>(context, listen: false)
        .filterLawyers(query, _selectedFilters);
  }

  void _onFilterToggled(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
    });
    _onSearchChanged();
  }

  @override
  Widget build(BuildContext context) {
    final directoryController = Provider.of<DirectoryController>(context);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _onSearchChanged(),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                hintText: 'Search for lawyers...',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _filters.map((filter) {
                final isSelected = _selectedFilters.contains(filter);
                return FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) => _onFilterToggled(filter),
                  selectedColor: Colors.deepPurple.shade200,
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: directoryController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: directoryController.filteredLawyers.length,
                    itemBuilder: (context, index) {
                      final lawyer = directoryController.filteredLawyers[index];
                      final tags = List<String>.from(lawyer['tags'] ?? []);
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12.0),
                          title: Text(
                              '${lawyer['first_name']} ${lawyer['last_name']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.phone, size: 20),
                                  const SizedBox(width: 8),
                                  Text(lawyer['phone']),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 20),
                                  const SizedBox(width: 8),
                                  Text(lawyer['address']),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8.0,
                                children: tags.map((tag) {
                                  return Chip(
                                    label: Text(tag),
                                    backgroundColor:
                                        Colors.deepPurpleAccent[200],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

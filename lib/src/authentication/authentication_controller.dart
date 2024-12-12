import 'authentication_service.dart';

class AuthController {
  final AuthenticationService _authenticationService = AuthenticationService();

  Future<String?> signIn(String email, String password) async {
    try {
      await _authenticationService.signInWithEmailAndPassword(email, password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> register(String email, String password) async {
    try {
      await _authenticationService.registerWithEmailAndPassword(
          email, password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

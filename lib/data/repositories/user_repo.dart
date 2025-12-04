import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';

class UserRepository {
  final FirebaseAuthService _authService;

  UserRepository(this._authService);

  Future<User?> login(String email, String password) {
    return _authService.login(email, password);
  }

  Future<User?> register(String email, String password) {
    return _authService.register(email, password);
  }

  Future<void> logout() {
    return _authService.logout();
  }

  Stream<User?> authStateChanges() {
    return _authService.authStateChanges();
  }
}

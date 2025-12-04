import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/user_repo.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository userRepository;

  AuthProvider(this.userRepository) {
    userRepository.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? _user;

  User? get user => _user;

  Stream<User?> get authState => userRepository.authStateChanges();

  Future<String?> login(String email, String password) async {
    try {
      await userRepository.login(email, password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> register(String email, String password) async {
    try {
      await userRepository.register(email, password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> logout() async {
    await userRepository.logout();
  }
}

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  StreamSubscription<User?>? _sub;

  AppUser? appUser;
  bool initializing = true;
  bool loading = false;
  String? error;

  AuthProvider(this._service) {
    _sub = _service.authChanges.listen(_onAuthChanged);
  }

  bool get isLoggedIn => _service.currentUser != null;
  bool get isVerified => _service.currentUser?.emailVerified ?? false;
  bool get isStaff => appUser?.isStaff ?? false;

  Future<void> _onAuthChanged(User? user) async {
    appUser = user == null ? null : await _service.fetchUser(user.uid);
    initializing = false;
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password) =>
      _run(() async {
        await _service.register(name: name, email: email, password: password);
        appUser = await _service.fetchUser(_service.currentUser!.uid);
      });

  Future<bool> login(String email, String password) =>
      _run(() => _service.login(email, password));

  Future<void> logout() => _service.logout();

  Future<bool> resendVerification() => _run(_service.resendVerification);

  /// Returns true if the email is now verified
  Future<bool> checkVerified() async {
    await _service.reloadUser();
    notifyListeners();
    return isVerified;
  }

  Future<bool> _run(Future<void> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await action();
      loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      error = _friendly(e.code);
    } catch (_) {
      error = 'Something went wrong. Please try again.';
    }
    loading = false;
    notifyListeners();
    return false;
  }

  String _friendly(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Authentication error ($code).';
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
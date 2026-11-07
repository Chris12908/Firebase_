import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(name);

    // Role is ALWAYS 'student' on signup. Staff are set manually in the console.
    await _db.collection('users').doc(user.uid).set({
      'name': name,
      'email': email.trim().toLowerCase(),
      'role': 'student',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await user.sendEmailVerification();
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() => _auth.signOut();

  Future<void> resendVerification() async =>
      _auth.currentUser?.sendEmailVerification();

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
    await _auth.currentUser?.getIdToken(true);
  }

  Future<AppUser?> fetchUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? AppUser.fromDoc(doc) : null;
  }
}

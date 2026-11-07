import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_1/providers/auth_provider.dart';
import 'package:firebase_1/screens/auth/login_screen.dart';
import 'package:firebase_1/services/auth_service.dart';
import 'package:firebase_1/utils/app_theme.dart';

/// A fake service, so the login screen can be tested without Firebase.
class FakeAuthService extends Fake implements AuthService {
  @override
  Stream<User?> get authChanges => const Stream<User?>.empty();

  @override
  User? get currentUser => null;
}

Widget buildLoginScreen() {
  return ChangeNotifierProvider(
    create: (_) => AuthProvider(FakeAuthService()),
    child: MaterialApp(theme: AppTheme.light, home: const LoginScreen()),
  );
}

void main() {
  testWidgets('shows errors when the form is empty', (tester) async {
    await tester.pumpWidget(buildLoginScreen());

    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('rejects a non-ALU email', (tester) async {
    await tester.pumpWidget(buildLoginScreen());

    await tester.enterText(
        find.byType(TextFormField).first, 'student@gmail.com');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.textContaining('Use your ALU email'), findsOneWidget);
  });
}

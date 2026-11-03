import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Verify your email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We sent a verification link to ${auth.appUser?.email ?? 'your email'}. '
                'Open it, then tap the button below.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final ok = await auth.checkVerified();
                    if (!ok) {
                      messenger.showSnackBar(const SnackBar(
                          content: Text('Email not verified yet.')));
                    }
                  },
                  child: const Text("I've verified my email"),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () async {
                  final ok = await auth.resendVerification();
                  messenger.showSnackBar(SnackBar(
                      content: Text(ok
                          ? 'Verification email sent.'
                          : auth.error ?? 'Could not send.')));
                },
                child: const Text('Resend email'),
              ),
              TextButton(
                onPressed: auth.logout,
                child: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
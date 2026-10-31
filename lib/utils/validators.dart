import 'constants.dart';

class Validators {
  static String? required(String? v, [String field = 'This field']) =>
      (v == null || v.trim().isEmpty) ? '$field is required' : null;

  static String? aluEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final email = v.trim().toLowerCase();
    final regex = RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]+$');
    if (!regex.hasMatch(email)) return 'Enter a valid email';
    final domain = email.split('@').last;
    if (!AppConstants.allowedDomains.contains(domain)) {
      return 'Use your ALU email (${AppConstants.allowedDomains.join(' or ')})';
    }
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'At least 8 characters';
    return null;
  }
}
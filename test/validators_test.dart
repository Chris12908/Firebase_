import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_1/utils/validators.dart';

void main() {
  group('Validators.aluEmail', () {
    test('rejects an empty email', () {
      expect(Validators.aluEmail(''), 'Email is required');
      expect(Validators.aluEmail(null), 'Email is required');
    });

    test('rejects a badly formatted email', () {
      expect(Validators.aluEmail('not-an-email'), 'Enter a valid email');
    });

    test('rejects a non-ALU domain', () {
      expect(Validators.aluEmail('john@gmail.com'),
          contains('Use your ALU email'));
    });

    test('accepts an alustudent.com email', () {
      expect(Validators.aluEmail('john@alustudent.com'), isNull);
    });

    test('accepts an alueducation.com email', () {
      expect(Validators.aluEmail('staff@alueducation.com'), isNull);
    });

    test('accepts uppercase letters and spaces around the email', () {
      expect(Validators.aluEmail('  John@ALUstudent.com '), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects an empty password', () {
      expect(Validators.password(''), 'Password is required');
    });

    test('rejects a password shorter than 8 characters', () {
      expect(Validators.password('short'), 'At least 8 characters');
    });

    test('accepts a password of 8 or more characters', () {
      expect(Validators.password('12345678'), isNull);
    });
  });

  group('Validators.required', () {
    test('rejects blank text', () {
      expect(Validators.required('   '), 'This field is required');
    });

    test('uses the field name in the message', () {
      expect(Validators.required('', 'Title'), 'Title is required');
    });

    test('accepts real text', () {
      expect(Validators.required('Broken tap', 'Title'), isNull);
    });
  });
}

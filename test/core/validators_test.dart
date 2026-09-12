import 'package:flutter_test/flutter_test.dart';
import 'package:students_system/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('requiredField returns null for valid string', () {
      expect(Validators.requiredField('محمد', 'الاسم'), isNull);
    });

    test('requiredField returns error for empty/null string', () {
      expect(Validators.requiredField('', 'الاسم'), contains('الاسم'));
      expect(Validators.requiredField(null, 'الاسم'), contains('الاسم'));
    });

    test('validateGrade accepts valid numeric grade 0..100', () {
      expect(Validators.validateGrade('95.5'), isNull);
      expect(Validators.validateGrade('100'), isNull);
      expect(Validators.validateGrade('0'), isNull);
    });

    test('validateGrade rejects invalid range or text', () {
      expect(Validators.validateGrade('105'), isNotNull);
      expect(Validators.validateGrade('-5'), isNotNull);
      expect(Validators.validateGrade('abc'), isNotNull);
    });

    test('validatePhone accepts optional empty or valid number', () {
      expect(Validators.validatePhone(''), isNull);
      expect(Validators.validatePhone(null), isNull);
      expect(Validators.validatePhone('0501234567'), isNull);
      expect(Validators.validatePhone('+966501234567'), isNull);
    });
  });
}

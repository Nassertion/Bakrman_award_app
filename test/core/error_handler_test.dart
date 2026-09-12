import 'package:flutter_test/flutter_test.dart';
import 'package:students_system/core/errors/error_handler.dart';

void main() {
  group('ErrorHandler Unit Tests', () {
    test('parseResponseError extracts Arabic error message for 401', () {
      final exc = ErrorHandler.parseResponseError(401, {'message': 'Unauthorized'});
      expect(exc.statusCode, equals(401));
      expect(exc.message, contains('غير صحيحة'));
    });

    test('parseResponseError extracts field errors map for 422', () {
      final exc = ErrorHandler.parseResponseError(422, {
        'success': false,
        'message': 'Validation failed',
        'errors': {
          'first_name': ['حقل الاسم الأول مطلوب'],
          'grade': ['الدرجة يجب أن تكون برقم صحيح']
        }
      });

      expect(exc.statusCode, equals(422));
      expect(exc.fieldErrors, isNotNull);
      expect(exc.fieldErrors!['first_name'], contains('حقل الاسم الأول مطلوب'));
    });
  });
}

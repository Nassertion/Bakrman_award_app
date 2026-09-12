import 'package:flutter_test/flutter_test.dart';
import 'package:students_system/features/students/domain/pagination_meta.dart';
import 'package:students_system/features/students/domain/student.dart';

void main() {
  group('Student Model & Pagination Unit Tests', () {
    test('Student.fromJson parses JSON correctly and computes full name', () {
      final json = {
        'id': 1,
        'first_name': 'أحمد',
        'second_name': 'سالم',
        'third_name': 'علي',
        'last_name': 'الغامدي',
        'gender': 'male',
        'governorate': 1,
        'class': 9,
        'school_name': 'مدرسة النموذجية',
        'grade': '98.5',
        'image_url': 'https://example.com/cert.jpg'
      };

      final student = Student.fromJson(json);

      expect(student.id, equals(1));
      expect(student.fullName, equals('أحمد سالم علي الغامدي'));
      expect(student.grade, equals(98.5));
      expect(student.schoolName, equals('مدرسة النموذجية'));
      expect(student.imageUrl, equals('https://example.com/cert.jpg'));
    });

    test('PaginatedStudentsResult parses flat list response', () {
      final jsonResponse = {
        'success': true,
        'data': [
          {
            'id': 10,
            'first_name': 'سارة',
            'last_name': 'خالد',
            'gender': 'female',
            'governorate': 2,
            'class': 12,
            'school_name': 'مكتب التعليم',
            'grade': 94.0
          }
        ]
      };

      final result = PaginatedStudentsResult.fromApiResponse(jsonResponse);

      expect(result.students.length, equals(1));
      expect(result.students.first.firstName, equals('سارة'));
      expect(result.totalCount, equals(1));
    });

    test('PaginatedStudentsResult parses nested paginated object response defensively', () {
      final jsonResponse = {
        'success': true,
        'data': {
          'current_page': 2,
          'last_page': 5,
          'total': 50,
          'data': [
            {
              'id': 42,
              'first_name': 'عبدالرحمن',
              'last_name': 'الشهري',
              'gender': 'male',
              'governorate': 3,
              'class': 10,
              'school_name': 'المدرسة الثانوية',
              'grade': 89.0
            }
          ]
        }
      };

      final result = PaginatedStudentsResult.fromApiResponse(jsonResponse);

      expect(result.students.length, equals(1));
      expect(result.totalCount, equals(50));
      expect(result.currentPage, equals(2));
      expect(result.lastPage, equals(5));
      expect(result.students.first.id, equals(42));
    });
  });
}

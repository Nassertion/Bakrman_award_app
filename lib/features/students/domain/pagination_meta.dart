import 'student.dart';

class PaginatedStudentsResult {
  final List<Student> students;
  final int totalCount;
  final int currentPage;
  final int lastPage;

  PaginatedStudentsResult({
    required this.students,
    required this.totalCount,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  factory PaginatedStudentsResult.fromApiResponse(dynamic responseData) {
    List<Student> studentsList = [];
    int total = 0;
    int current = 1;
    int last = 1;

    dynamic rawList;

    if (responseData is List) {
      rawList = responseData;
    } else if (responseData is Map<String, dynamic>) {
      final dataField = responseData['data'];
      if (dataField is List) {
        rawList = dataField;
      } else if (dataField is Map<String, dynamic>) {
        if (dataField['data'] is List) {
          rawList = dataField['data'];
        }
        total = int.tryParse(dataField['total']?.toString() ?? '0') ?? 0;
        current = int.tryParse(dataField['current_page']?.toString() ?? '1') ?? 1;
        last = int.tryParse(dataField['last_page']?.toString() ?? '1') ?? 1;
      }
    }

    if (rawList is List) {
      studentsList = rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => Student.fromJson(item))
          .toList();
      if (total == 0) {
        total = studentsList.length;
      }
    }

    return PaginatedStudentsResult(
      students: studentsList,
      totalCount: total,
      currentPage: current,
      lastPage: last,
    );
  }
}

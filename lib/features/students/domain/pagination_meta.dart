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
    } else if (responseData is Map) {
      final mapData = Map<String, dynamic>.from(responseData);

      List? findList(Map<String, dynamic> map) {
        for (final key in ['data', 'students', 'items', 'results', 'records']) {
          final val = map[key];
          if (val is List) return val;
        }
        return null;
      }

      final topList = findList(mapData);
      if (topList != null) {
        rawList = topList;
      } else if (mapData['data'] is Map) {
        final nestedMap = Map<String, dynamic>.from(mapData['data'] as Map);
        rawList = findList(nestedMap);

        total = int.tryParse(nestedMap['total']?.toString() ?? '') ??
            int.tryParse(nestedMap['total_count']?.toString() ?? '') ??
            0;
        current = int.tryParse(nestedMap['current_page']?.toString() ?? '') ??
            int.tryParse(nestedMap['page']?.toString() ?? '') ??
            1;
        last = int.tryParse(nestedMap['last_page']?.toString() ?? '') ??
            int.tryParse(nestedMap['total_pages']?.toString() ?? '') ??
            1;
      }

      if (total == 0) {
        total = int.tryParse(mapData['total']?.toString() ?? '') ??
            int.tryParse(mapData['total_count']?.toString() ?? '') ??
            int.tryParse(mapData['count']?.toString() ?? '') ??
            0;

        if (mapData['meta'] is Map) {
          final meta = Map<String, dynamic>.from(mapData['meta'] as Map);
          total = total != 0 ? total : (int.tryParse(meta['total']?.toString() ?? '') ?? 0);
          current = int.tryParse(meta['current_page']?.toString() ?? '') ?? current;
          last = int.tryParse(meta['last_page']?.toString() ?? '') ?? last;
        }
      }
    }

    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map) {
          try {
            final itemMap = Map<String, dynamic>.from(item);
            studentsList.add(Student.fromJson(itemMap));
          } catch (_) {
            // Defensive skip of invalid item
          }
        }
      }
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

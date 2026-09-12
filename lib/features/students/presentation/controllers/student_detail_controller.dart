import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/student.dart';
import 'student_list_controller.dart';

final studentDetailProvider =
    FutureProvider.family<Student, int>((ref, id) async {
  final repository = ref.watch(studentRepositoryProvider);
  return await repository.getStudent(id);
});

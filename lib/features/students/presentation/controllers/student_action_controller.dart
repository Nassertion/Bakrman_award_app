import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/student_repository.dart';
import 'student_detail_controller.dart';
import 'student_list_controller.dart';

class StudentActionState {
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;

  const StudentActionState({
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  StudentActionState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return StudentActionState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class StudentActionController extends StateNotifier<StudentActionState> {
  final StudentRepository _repository;
  final Ref _ref;

  StudentActionController(this._repository, this._ref)
      : super(const StudentActionState());

  Future<bool> updateStudent(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null, isSuccess: false);
    try {
      await _repository.updateStudent(id, data);
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      _ref.read(studentListControllerProvider.notifier).fetchStudents();
      _ref.invalidate(studentDetailProvider(id));
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteStudent(int id) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null, isSuccess: false);
    try {
      await _repository.deleteStudent(id);
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      _ref.read(studentListControllerProvider.notifier).fetchStudents();
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }
}

final studentActionControllerProvider =
    StateNotifierProvider<StudentActionController, StudentActionState>((ref) {
  final repo = ref.watch(studentRepositoryProvider);
  return StudentActionController(repo, ref);
});

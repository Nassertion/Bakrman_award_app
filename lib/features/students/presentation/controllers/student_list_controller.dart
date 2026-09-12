import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/csv_exporter.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../data/student_repository.dart';
import '../../domain/pagination_meta.dart';
import '../../domain/student_filter.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return StudentRepository(dioClient);
});

final studentFilterProvider = StateProvider<StudentFilter>((ref) => const StudentFilter());

class StudentListState {
  final bool isLoading;
  final String? errorMessage;
  final PaginatedStudentsResult? result;

  const StudentListState({
    this.isLoading = true,
    this.errorMessage,
    this.result,
  });

  StudentListState copyWith({
    bool? isLoading,
    String? errorMessage,
    PaginatedStudentsResult? result,
  }) {
    return StudentListState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      result: result ?? this.result,
    );
  }
}

class StudentListController extends StateNotifier<StudentListState> {
  final StudentRepository _repository;
  final Ref _ref;

  StudentListController(this._repository, this._ref) : super(const StudentListState()) {
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final filter = _ref.read(studentFilterProvider);
      final result = await _repository.getStudents(filter);
      state = state.copyWith(
        isLoading: false,
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateFilter(StudentFilter newFilter) async {
    _ref.read(studentFilterProvider.notifier).state = newFilter;
    await fetchStudents();
  }

  Future<void> clearFilter() async {
    _ref.read(studentFilterProvider.notifier).state = const StudentFilter();
    await fetchStudents();
  }

  Future<bool> exportCsv() async {
    try {
      final filter = _ref.read(studentFilterProvider);
      final rawData = await _repository.exportCsv(filter);
      final fileName = 'students_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      return await CsvExporter.saveAndShareCsv(rawData, fileName);
    } catch (e) {
      return false;
    }
  }
}

final studentListControllerProvider =
    StateNotifierProvider<StudentListController, StudentListState>((ref) {
  final repo = ref.watch(studentRepositoryProvider);
  return StudentListController(repo, ref);
});

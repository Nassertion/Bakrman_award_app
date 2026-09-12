import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/registration_repository.dart';
import '../domain/registration_form_state.dart';

final registrationRepositoryProvider = Provider<RegistrationRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return RegistrationRepository(dioClient);
});

class RegistrationController extends StateNotifier<RegistrationFormState> {
  final RegistrationRepository _repository;

  RegistrationController(this._repository)
      : super(const RegistrationFormState());

  Future<bool> submitStudent({
    required String firstName,
    required String secondName,
    required String thirdName,
    required String lastName,
    required String gender,
    required int governorate,
    required int classLevel,
    required String schoolName,
    required double grade,
    required XFile certImage,
    List<XFile>? additionalImages,
    String? phone1,
    String? phone2,
    String? address,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final studentId = await _repository.submitStudentRegistration(
        firstName: firstName,
        secondName: secondName,
        thirdName: thirdName,
        lastName: lastName,
        gender: gender,
        governorate: governorate,
        classLevel: classLevel,
        schoolName: schoolName,
        grade: grade,
        certImage: certImage,
        additionalImages: additionalImages,
        phone1: phone1,
        phone2: phone2,
        address: address,
      );

      state = state.copyWith(
        isSubmitting: false,
        submittedStudentId: studentId,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void resetState() {
    state = const RegistrationFormState();
  }
}

final registrationControllerProvider =
    StateNotifierProvider<RegistrationController, RegistrationFormState>((ref) {
  final repo = ref.watch(registrationRepositoryProvider);
  return RegistrationController(repo);
});

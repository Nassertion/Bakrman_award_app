class RegistrationFormState {
  final bool isSubmitting;
  final String? errorMessage;
  final int? submittedStudentId;

  const RegistrationFormState({
    this.isSubmitting = false,
    this.errorMessage,
    this.submittedStudentId,
  });

  RegistrationFormState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    int? submittedStudentId,
  }) {
    return RegistrationFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      submittedStudentId: submittedStudentId ?? this.submittedStudentId,
    );
  }
}

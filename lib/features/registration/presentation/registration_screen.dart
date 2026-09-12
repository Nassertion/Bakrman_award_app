import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/responsive_layout.dart';
import 'registration_controller.dart';
import 'widgets/cert_image_picker.dart';
import 'widgets/registration_success_dialog.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal Info
  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _thirdNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _selectedGender = 'male';

  // Academic Info
  int _selectedGovernorate = 1;
  int _selectedClass = 9;
  final _schoolNameController = TextEditingController();
  final _gradeController = TextEditingController();

  // Contact Info
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _addressController = TextEditingController();

  // Images
  XFile? _certImage;
  XFile? _additionalImage1;

  bool _certImageError = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _thirdNameController.dispose();
    _lastNameController.dispose();
    _schoolNameController.dispose();
    _gradeController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _firstNameController.clear();
    _secondNameController.clear();
    _thirdNameController.clear();
    _lastNameController.clear();
    _schoolNameController.clear();
    _gradeController.clear();
    _phone1Controller.clear();
    _phone2Controller.clear();
    _addressController.clear();
    setState(() {
      _selectedGender = 'male';
      _selectedGovernorate = 1;
      _selectedClass = 9;
      _certImage = null;
      _additionalImage1 = null;
      _certImageError = false;
    });
    ref.read(registrationControllerProvider.notifier).resetState();
  }

  Future<void> _submitForm() async {
    setState(() {
      _certImageError = _certImage == null;
    });

    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid || _certImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى تصحيح الأخطاء ورفع صورة الشهادة الدراسية المطلوبة.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final additionalImages = <XFile>[];
    if (_additionalImage1 != null) additionalImages.add(_additionalImage1!);

    final success = await ref
        .read(registrationControllerProvider.notifier)
        .submitStudent(
          firstName: _firstNameController.text.trim(),
          secondName: _secondNameController.text.trim(),
          thirdName: _thirdNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          gender: _selectedGender,
          governorate: _selectedGovernorate,
          classLevel: _selectedClass,
          schoolName: _schoolNameController.text.trim(),
          grade: double.parse(_gradeController.text.trim()),
          certImage: _certImage!,
          additionalImages: additionalImages.isNotEmpty
              ? additionalImages
              : null,
          phone1: _phone1Controller.text.trim().isNotEmpty
              ? _phone1Controller.text.trim()
              : null,
          phone2: _phone2Controller.text.trim().isNotEmpty
              ? _phone2Controller.text.trim()
              : null,
          address: _addressController.text.trim().isNotEmpty
              ? _addressController.text.trim()
              : null,
        );

    if (success && mounted) {
      final state = ref.read(registrationControllerProvider);
      if (state.submittedStudentId != null) {
        RegistrationSuccessDialog.show(
          context,
          state.submittedStudentId!,
          _resetForm,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationControllerProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              // padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(child: Text(AppConstants.appName)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.admin_panel_settings_outlined, size: 16),
              label: const Text('لوحة التحكم'),
              onPressed: () => context.go('/admin/login'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 64 : 16,
          vertical: 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Header Section
                  CustomCard(
                    color: AppColors.primaryContainer,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'نموذج تسجيل بيانات الطلاب',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'يرجى إدخال البيانات الشخصية والأكاديمية بدقة ورفع صورة الشهادة المدرسية لإتمام التسجيل في المنظومة.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.primaryDark.withOpacity(
                                        0.8,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (isDesktop) ...[
                          const SizedBox(width: 24),
                          const Icon(
                            Icons.verified_user_rounded,
                            size: 64,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (state.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.errorMessage!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // SECTION 1: Personal Information
                  _buildSectionHeader(
                    '١. البيانات الشخصية',
                    Icons.person_rounded,
                  ),
                  const SizedBox(height: 12),
                  CustomCard(
                    child: Column(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 600) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      label: 'الاسم الأول',
                                      hint: 'مثال: محمد',
                                      controller: _firstNameController,
                                      validator: (v) =>
                                          Validators.requiredField(
                                            v,
                                            'الاسم الأول',
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: AppTextField(
                                      label: 'اسم الأب',
                                      hint: 'مثال: عبد الله',
                                      controller: _secondNameController,
                                      validator: (v) =>
                                          Validators.requiredField(
                                            v,
                                            'اسم الأب',
                                          ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                AppTextField(
                                  label: 'الاسم الأول',
                                  hint: 'مثال: محمد',
                                  controller: _firstNameController,
                                  validator: (v) => Validators.requiredField(
                                    v,
                                    'الاسم الأول',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: 'اسم الأب',
                                  hint: 'مثال: عبد الله',
                                  controller: _secondNameController,
                                  validator: (v) =>
                                      Validators.requiredField(v, 'اسم الأب'),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 600) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      label: 'اسم الجد',
                                      hint: 'مثال: سليم',
                                      controller: _thirdNameController,
                                      validator: (v) =>
                                          Validators.requiredField(
                                            v,
                                            'اسم الجد',
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: AppTextField(
                                      label: 'اسم العائلة',
                                      hint: 'مثال: العتيبي',
                                      controller: _lastNameController,
                                      validator: (v) =>
                                          Validators.requiredField(
                                            v,
                                            'اسم العائلة',
                                          ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                AppTextField(
                                  label: 'اسم الجد',
                                  hint: 'مثال: سليم',
                                  controller: _thirdNameController,
                                  validator: (v) =>
                                      Validators.requiredField(v, 'اسم الجد'),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: 'اسم العائلة',
                                  hint: 'مثال: العتيبي',
                                  controller: _lastNameController,
                                  validator: (v) => Validators.requiredField(
                                    v,
                                    'اسم العائلة',
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'الجنس',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('ذكر'),
                                    value: 'male',
                                    groupValue: _selectedGender,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) =>
                                        setState(() => _selectedGender = val!),
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('أنثى'),
                                    value: 'female',
                                    groupValue: _selectedGender,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) =>
                                        setState(() => _selectedGender = val!),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SECTION 2: Academic Information
                  _buildSectionHeader(
                    '٢. البيانات الأكاديمية',
                    Icons.school_outlined,
                  ),
                  const SizedBox(height: 12),
                  CustomCard(
                    child: Column(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 600) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildDropdownField<int>(
                                      label: 'المحافظة',
                                      value: _selectedGovernorate,
                                      items: AppConstants.governorates.entries
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e.key,
                                              child: Text(e.value),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) => setState(
                                        () => _selectedGovernorate = val!,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdownField<int>(
                                      label: 'الصف الدراسي',
                                      value: _selectedClass,
                                      items: AppConstants.classes.entries
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e.key,
                                              child: Text(e.value),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) =>
                                          setState(() => _selectedClass = val!),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                _buildDropdownField<int>(
                                  label: 'المحافظة',
                                  value: _selectedGovernorate,
                                  items: AppConstants.governorates.entries
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e.key,
                                          child: Text(e.value),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) => setState(
                                    () => _selectedGovernorate = val!,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildDropdownField<int>(
                                  label: 'الصف الدراسي',
                                  value: _selectedClass,
                                  items: AppConstants.classes.entries
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e.key,
                                          child: Text(e.value),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedClass = val!),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 600) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      label: 'اسم المدرسة',
                                      hint: 'مثال: مدرسة الملك فهد النموذجية',
                                      controller: _schoolNameController,
                                      validator: (v) =>
                                          Validators.requiredField(
                                            v,
                                            'اسم المدرسة',
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: AppTextField(
                                      label: 'المعدل / الدرجة',
                                      hint: 'مثال: 95.5',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      controller: _gradeController,
                                      validator: Validators.validateGrade,
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                AppTextField(
                                  label: 'اسم المدرسة',
                                  hint: 'مثال: مدرسة الملك فهد النموذجية',
                                  controller: _schoolNameController,
                                  validator: (v) => Validators.requiredField(
                                    v,
                                    'اسم المدرسة',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: 'المعدل / الدرجة',
                                  hint: 'مثال: 95.5',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  controller: _gradeController,
                                  validator: Validators.validateGrade,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SECTION 3: Contact Information
                  _buildSectionHeader(
                    '٣. بيانات التواصل',
                    Icons.phone_android_rounded,
                  ),
                  const SizedBox(height: 12),
                  CustomCard(
                    child: Column(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 600) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      label: 'رقم الجوال الأول (اختياري)',
                                      hint: '05xxxxxxxx',
                                      keyboardType: TextInputType.phone,
                                      controller: _phone1Controller,
                                      validator: Validators.validatePhone,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: AppTextField(
                                      label: 'رقم الجوال الثاني (اختياري)',
                                      hint: '05xxxxxxxx',
                                      keyboardType: TextInputType.phone,
                                      controller: _phone2Controller,
                                      validator: Validators.validatePhone,
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                AppTextField(
                                  label: 'رقم الجوال الأول (اختياري)',
                                  hint: '05xxxxxxxx',
                                  keyboardType: TextInputType.phone,
                                  controller: _phone1Controller,
                                  validator: Validators.validatePhone,
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: 'رقم الجوال الثاني (اختياري)',
                                  hint: '05xxxxxxxx',
                                  keyboardType: TextInputType.phone,
                                  controller: _phone2Controller,
                                  validator: Validators.validatePhone,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'العنوان السكني (اختياري)',
                          hint: 'اسم الحي والشارع',
                          controller: _addressController,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SECTION 4: Documents Upload
                  _buildSectionHeader(
                    '٤. المستندات والشهادات',
                    Icons.file_present_rounded,
                  ),
                  const SizedBox(height: 12),
                  CustomCard(
                    child: Column(
                      children: [
                        CertImagePicker(
                          label: 'صورة الشهادة الدراسية',
                          subLabel: 'يدعم صيغ JPG, PNG حتى 5 ميجابايت',
                          isRequired: true,
                          selectedFile: _certImage,
                          errorText: _certImageError
                              ? 'يرجى اختيار صورة الشهادة المطلوبة'
                              : null,
                          onImageSelected: (file) {
                            setState(() {
                              _certImage = file;
                              if (file != null) _certImageError = false;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        CertImagePicker(
                          label: 'صورة إضافية (اختياري)',
                          subLabel: 'وثيقة داعمة أو صورة ثانية',
                          selectedFile: _additionalImage1,
                          onImageSelected: (file) {
                            setState(() {
                              _additionalImage1 = file;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Action Button
                  AppButton(
                    text: 'إرسال طلب التسجيل',
                    icon: Icons.send_rounded,
                    height: 54,
                    isLoading: state.isSubmitting,
                    onPressed: _submitForm,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}

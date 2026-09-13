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
import '../../registration/presentation/registration_controller.dart';
import '../../registration/presentation/widgets/cert_image_picker.dart';

class AdminRegistrationScreen extends ConsumerStatefulWidget {
  const AdminRegistrationScreen({super.key});

  @override
  ConsumerState<AdminRegistrationScreen> createState() => _AdminRegistrationScreenState();
}

class _AdminRegistrationScreenState extends ConsumerState<AdminRegistrationScreen> {
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
          content: Text('يرجى تصحيح الأخطاء ورفع صورة الشهادة الدراسية المطلوبة.'),
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
          additionalImages: additionalImages.isNotEmpty ? additionalImages : null,
          phone1: _phone1Controller.text.trim().isNotEmpty ? _phone1Controller.text.trim() : null,
          phone2: _phone2Controller.text.trim().isNotEmpty ? _phone2Controller.text.trim() : null,
          address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        );

    if (success && mounted) {
      final submittedId = ref.read(registrationControllerProvider).submittedStudentId;
      _resetForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'تمت إضافة الطالب بنجاح',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 4),
        ),
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
              SizedBox(width: 10),
              Text('تمت الإضافة بنجاح'),
            ],
          ),
          content: Text(
            submittedId != null && submittedId > 0
                ? 'تم تسجيل بيانات الطالب وتحديث القائمة بنجاح.\nرقم المعرف المخصص: #$submittedId'
                : 'تم تسجيل بيانات الطالب وتحديث القائمة بنجاح.',
            style: const TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              child: const Text('إضافة طالب آخر'),
              onPressed: () => Navigator.of(dialogCtx).pop(),
            ),
            ElevatedButton(
              child: const Text('العودة للوحة التحكم'),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                context.go('/admin');
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationControllerProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'العودة للوحة التحكم',
          onPressed: () => context.go('/admin'),
        ),
        title: const Text('تسجيل طالب جديد - لوحة الإدارة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'إعادة ضبط النموذج',
            onPressed: _resetForm,
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
                  // Admin Registration Banner
                  CustomCard(
                    color: AppColors.primaryContainer,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'إضافة طالب جديد في المنظومة',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'نموذج الإدخال المباشر للطلاب من قبل مسؤول النظام. بعد الإضافة سينعكس الطالب فوراً في السجلات.',
                                style: TextStyle(color: AppColors.primaryDark, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.person_add_alt_1_rounded, size: 40, color: AppColors.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (state.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.errorMessage!,
                              style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // SECTION 1: Personal Info
                  _buildSectionHeader('١. البيانات الشخصية', Icons.person_rounded),
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
                                      validator: (v) => Validators.requiredField(v, 'الاسم الأول'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: AppTextField(
                                      label: 'اسم الأب',
                                      hint: 'مثال: عبد الله',
                                      controller: _secondNameController,
                                      validator: (v) => Validators.requiredField(v, 'اسم الأب'),
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
                                  validator: (v) => Validators.requiredField(v, 'الاسم الأول'),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: 'اسم الأب',
                                  hint: 'مثال: عبد الله',
                                  controller: _secondNameController,
                                  validator: (v) => Validators.requiredField(v, 'اسم الأب'),
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
                                      validator: (v) => Validators.requiredField(v, 'اسم الجد'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: AppTextField(
                                      label: 'اسم العائلة',
                                      hint: 'مثال: العتيبي',
                                      controller: _lastNameController,
                                      validator: (v) => Validators.requiredField(v, 'اسم العائلة'),
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
                                  validator: (v) => Validators.requiredField(v, 'اسم الجد'),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: 'اسم العائلة',
                                  hint: 'مثال: العتيبي',
                                  controller: _lastNameController,
                                  validator: (v) => Validators.requiredField(v, 'اسم العائلة'),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('الجنس', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('ذكر'),
                                    value: 'male',
                                    groupValue: _selectedGender,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) => setState(() => _selectedGender = val!),
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('أنثى'),
                                    value: 'female',
                                    groupValue: _selectedGender,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) => setState(() => _selectedGender = val!),
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

                  // SECTION 2: Academic Info
                  _buildSectionHeader('٢. البيانات الأكاديمية', Icons.school_outlined),
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
                                          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                                          .toList(),
                                      onChanged: (val) => setState(() => _selectedGovernorate = val!),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdownField<int>(
                                      label: 'الصف الدراسي',
                                      value: _selectedClass,
                                      items: AppConstants.classes.entries
                                          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                                          .toList(),
                                      onChanged: (val) => setState(() => _selectedClass = val!),
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
                                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                                      .toList(),
                                  onChanged: (val) => setState(() => _selectedGovernorate = val!),
                                ),
                                const SizedBox(height: 16),
                                _buildDropdownField<int>(
                                  label: 'الصف الدراسي',
                                  value: _selectedClass,
                                  items: AppConstants.classes.entries
                                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                                      .toList(),
                                  onChanged: (val) => setState(() => _selectedClass = val!),
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
                                      validator: (v) => Validators.requiredField(v, 'اسم المدرسة'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: AppTextField(
                                      label: 'المعدل / الدرجة',
                                      hint: 'مثال: 95.5',
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                                  validator: (v) => Validators.requiredField(v, 'اسم المدرسة'),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: 'المعدل / الدرجة',
                                  hint: 'مثال: 95.5',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

                  // SECTION 3: Contact Info
                  _buildSectionHeader('٣. بيانات التواصل', Icons.phone_android_rounded),
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
                  _buildSectionHeader('٤. المستندات والشهادات', Icons.file_present_rounded),
                  const SizedBox(height: 12),
                  CustomCard(
                    child: Column(
                      children: [
                        CertImagePicker(
                          label: 'صورة الشهادة الدراسية',
                          subLabel: 'يدعم صيغ JPG, PNG حتى 5 ميجابايت',
                          isRequired: true,
                          selectedFile: _certImage,
                          errorText: _certImageError ? 'يرجى اختيار صورة الشهادة المطلوبة' : null,
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
                    text: 'تأكيد وحفظ بيانات الطالب',
                    icon: Icons.save_rounded,
                    height: 54,
                    isLoading: state.isSubmitting,
                    onPressed: state.isSubmitting ? null : _submitForm,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/config/constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/student.dart';
import '../controllers/student_action_controller.dart';

class EditStudentDialog extends ConsumerStatefulWidget {
  final Student student;

  const EditStudentDialog({super.key, required this.student});

  static Future<bool?> show(BuildContext context, Student student) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditStudentDialog(student: student),
    );
  }

  @override
  ConsumerState<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends ConsumerState<EditStudentDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _secondNameController;
  late TextEditingController _thirdNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _schoolNameController;
  late TextEditingController _gradeController;

  late String _gender;
  late int _governorate;
  late int _classLevel;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _firstNameController = TextEditingController(text: s.firstName);
    _secondNameController = TextEditingController(text: s.secondName ?? '');
    _thirdNameController = TextEditingController(text: s.thirdName ?? '');
    _lastNameController = TextEditingController(text: s.lastName);
    _schoolNameController = TextEditingController(text: s.schoolName);
    _gradeController = TextEditingController(text: s.grade.toString());

    _gender = s.gender;
    _governorate = s.governorate is int
        ? s.governorate
        : int.tryParse(s.governorate.toString()) ?? 1;
    _classLevel = s.classLevel is int
        ? s.classLevel
        : int.tryParse(s.classLevel.toString()) ?? 9;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _thirdNameController.dispose();
    _lastNameController.dispose();
    _schoolNameController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedData = <String, dynamic>{
        'first_name': _firstNameController.text.trim(),
        'second_name': _secondNameController.text.trim(),
        'third_name': _thirdNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'gender': _gender,
        'governorate': _governorate,
        'class': _classLevel,
        'school_name': _schoolNameController.text.trim(),
        'grade': double.parse(_gradeController.text.trim()),
      };

      final success = await ref
          .read(studentActionControllerProvider.notifier)
          .updateStudent(widget.student.id, updatedData);

      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(studentActionControllerProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تعديل بيانات الطالب',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'طالب #${widget.student.id}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  if (actionState.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        actionState.errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 450) {
                        return Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'الاسم الأول',
                                controller: _firstNameController,
                                validator: (v) => Validators.requiredField(v, 'الاسم الأول'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                label: 'اسم الأب',
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
                            controller: _firstNameController,
                            validator: (v) => Validators.requiredField(v, 'الاسم الأول'),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: 'اسم الأب',
                            controller: _secondNameController,
                            validator: (v) => Validators.requiredField(v, 'اسم الأب'),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 450) {
                        return Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'اسم الجد',
                                controller: _thirdNameController,
                                validator: (v) => Validators.requiredField(v, 'اسم الجد'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                label: 'اسم العائلة',
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
                            controller: _thirdNameController,
                            validator: (v) => Validators.requiredField(v, 'اسم الجد'),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: 'اسم العائلة',
                            controller: _lastNameController,
                            validator: (v) => Validators.requiredField(v, 'اسم العائلة'),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final govField = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('المحافظة', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            isExpanded: true,
                            value: _governorate,
                            items: AppConstants.governorates.entries
                                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: (val) => setState(() => _governorate = val!),
                          ),
                        ],
                      );

                      final classField = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('الصف الدراسي', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            isExpanded: true,
                            value: _classLevel,
                            items: AppConstants.classes.entries
                                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: (val) => setState(() => _classLevel = val!),
                          ),
                        ],
                      );

                      if (constraints.maxWidth > 450) {
                        return Row(
                          children: [
                            Expanded(child: govField),
                            const SizedBox(width: 12),
                            Expanded(child: classField),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          govField,
                          const SizedBox(height: 12),
                          classField,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 450) {
                        return Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'اسم المدرسة',
                                controller: _schoolNameController,
                                validator: (v) => Validators.requiredField(v, 'اسم المدرسة'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                label: 'المعدل / الدرجة',
                                controller: _gradeController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                            controller: _schoolNameController,
                            validator: (v) => Validators.requiredField(v, 'اسم المدرسة'),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: 'المعدل / الدرجة',
                            controller: _gradeController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: Validators.validateGrade,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الجنس', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('ذكر'),
                              value: 'male',
                              groupValue: _gender,
                              activeColor: AppColors.primary,
                              onChanged: (val) => setState(() => _gender = val!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('أنثى'),
                              value: 'female',
                              groupValue: _gender,
                              activeColor: AppColors.primary,
                              onChanged: (val) => setState(() => _gender = val!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('إلغاء'),
                      ),
                      const SizedBox(width: 12),
                      AppButton(
                        text: 'حفظ التغييرات',
                        isLoading: actionState.isSubmitting,
                        onPressed: _onSave,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

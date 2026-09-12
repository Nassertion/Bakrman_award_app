import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/config/constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/student_list_controller.dart';

class StudentFilterDrawer extends ConsumerStatefulWidget {
  const StudentFilterDrawer({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const StudentFilterDrawer(),
    );
  }

  @override
  ConsumerState<StudentFilterDrawer> createState() => _StudentFilterDrawerState();
}

class _StudentFilterDrawerState extends ConsumerState<StudentFilterDrawer> {
  int? _classLevel;
  String? _gender;
  int? _governorate;
  late TextEditingController _schoolController;
  late TextEditingController _gradeMoreThanController;
  late TextEditingController _gradeLessThanController;
  String? _sortBy;
  String? _sortOrder;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(studentFilterProvider);
    _classLevel = filter.classLevel;
    _gender = filter.gender;
    _governorate = filter.governorate;
    _schoolController = TextEditingController(text: filter.schoolName ?? '');
    _gradeMoreThanController = TextEditingController(text: filter.gradeMoreThan?.toString() ?? '');
    _gradeLessThanController = TextEditingController(text: filter.gradeLessThan?.toString() ?? '');
    _sortBy = filter.sortBy;
    _sortOrder = filter.sortOrder;
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _gradeMoreThanController.dispose();
    _gradeLessThanController.dispose();
    super.dispose();
  }

  void _apply() {
    final newFilter = ref.read(studentFilterProvider).copyWith(
          classLevel: _classLevel,
          gender: _gender,
          governorate: _governorate,
          schoolName: _schoolController.text.trim().isNotEmpty ? _schoolController.text.trim() : null,
          gradeMoreThan: double.tryParse(_gradeMoreThanController.text.trim()),
          gradeLessThan: double.tryParse(_gradeLessThanController.text.trim()),
          sortBy: _sortBy,
          sortOrder: _sortOrder,
          clearClass: _classLevel == null,
          clearGender: _gender == null,
          clearGovernorate: _governorate == null,
        );

    ref.read(studentListControllerProvider.notifier).updateFilter(newFilter);
    Navigator.of(context).pop();
  }

  void _reset() {
    ref.read(studentListControllerProvider.notifier).clearFilter();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_alt_rounded, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  'تصفية وفرز الطلاب',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),

            // Class Filter
            const Text('الصف الدراسي', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int?>(
              value: _classLevel,
              decoration: const InputDecoration(hintText: 'الكل'),
              items: [
                const DropdownMenuItem(value: null, child: Text('جميع الصفوف')),
                ...AppConstants.classes.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))),
              ],
              onChanged: (val) => setState(() => _classLevel = val),
            ),
            const SizedBox(height: 16),

            // Gender Filter
            const Text('الجنس', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String?>(
              value: _gender,
              decoration: const InputDecoration(hintText: 'الكل'),
              items: const [
                DropdownMenuItem(value: null, child: Text('الكل (ذكور وإناث)')),
                DropdownMenuItem(value: 'male', child: Text('ذكور')),
                DropdownMenuItem(value: 'female', child: Text('إناث')),
              ],
              onChanged: (val) => setState(() => _gender = val),
            ),
            const SizedBox(height: 16),

            // Governorate Filter
            const Text('المحافظة', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int?>(
              value: _governorate,
              decoration: const InputDecoration(hintText: 'الكل'),
              items: [
                const DropdownMenuItem(value: null, child: Text('جميع المحافظات')),
                ...AppConstants.governorates.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))),
              ],
              onChanged: (val) => setState(() => _governorate = val),
            ),
            const SizedBox(height: 16),

            // School Name
            const Text('اسم المدرسة', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _schoolController,
              decoration: const InputDecoration(hintText: 'أدخل اسم المدرسة'),
            ),
            const SizedBox(height: 16),

            // Grade Range
            const Text('نطاق الدرجة / المعدل', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _gradeMoreThanController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(hintText: 'أكبر من (مثال: 90)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _gradeLessThanController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(hintText: 'أقل من (مثال: 100)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sorting
            const Text('ترتيب حسب', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _sortBy,
                    decoration: const InputDecoration(hintText: 'حسب'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('افتراضي')),
                      DropdownMenuItem(value: 'grade', child: Text('الدرجة / المعدل')),
                    ],
                    onChanged: (val) => setState(() => _sortBy = val),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _sortOrder,
                    decoration: const InputDecoration(hintText: 'الاتجاه'),
                    items: const [
                      DropdownMenuItem(value: 'desc', child: Text('تنازلي (الأعلى أولاً)')),
                      DropdownMenuItem(value: 'asc', child: Text('تصاعدي (الأدنى أولاً)')),
                    ],
                    onChanged: (val) => setState(() => _sortOrder = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    child: const Text('إعادة ضبط'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'تطبيق الفلترة',
                    onPressed: _apply,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

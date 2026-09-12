import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../domain/student.dart';
import 'controllers/student_list_controller.dart';
import 'widgets/student_filter_drawer.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة وجميع سجلات الطلاب'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: StudentListContent(),
      ),
    );
  }
}

class StudentListContent extends ConsumerStatefulWidget {
  const StudentListContent({super.key});

  @override
  ConsumerState<StudentListContent> createState() => _StudentListContentState();
}

class _StudentListContentState extends ConsumerState<StudentListContent> {
  late TextEditingController _searchController;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(studentFilterProvider);
    _searchController = TextEditingController(text: filter.search ?? '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmit(String query) {
    final currentFilter = ref.read(studentFilterProvider);
    final updated = currentFilter.copyWith(search: query.trim());
    ref.read(studentListControllerProvider.notifier).updateFilter(updated);
  }

  void _onExportCsv() async {
    setState(() => _isExporting = true);
    final success = await ref.read(studentListControllerProvider.notifier).exportCsv();
    setState(() => _isExporting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'تم تصدير ملف CSV بنجاح وتنزيله على الجهاز.'
                : 'حدث خطأ أثناء تصدير ملف CSV.',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentListControllerProvider);
    final filter = ref.watch(studentFilterProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Column(
      children: [
        // Action Bar (Search, Filter, Export, Refresh)
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            final searchField = TextField(
              controller: _searchController,
              onSubmitted: _onSearchSubmit,
              decoration: InputDecoration(
                hintText: 'البحث عن طالب (الاسم أو المدرسة)...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchSubmit('');
                        },
                      )
                    : null,
              ),
            );

            final actionButtons = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.filter_alt_outlined, size: 18),
                  label: Text(filter.hasActiveFilters ? 'الفلاتر (نشطة)' : 'تصفية'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: filter.hasActiveFilters ? AppColors.accent : AppColors.primary,
                    side: BorderSide(
                      color: filter.hasActiveFilters ? AppColors.accent : AppColors.primary,
                    ),
                  ),
                  onPressed: () => StudentFilterDrawer.show(context),
                ),
                const SizedBox(width: 8),
                AppButton(
                  text: 'تصدير CSV',
                  icon: Icons.download_rounded,
                  variant: AppButtonVariant.secondary,
                  isLoading: _isExporting,
                  onPressed: _onExportCsv,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'تحديث السجلات',
                  onPressed: () => ref.read(studentListControllerProvider.notifier).fetchStudents(),
                ),
              ],
            );

            if (isWide) {
              return Row(
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: 16),
                  actionButtons,
                ],
              );
            }
            return Column(
              children: [
                searchField,
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: actionButtons,
                ),
              ],
            );
          },
        ),

        if (filter.hasActiveFilters) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Chip(
                avatar: Icon(Icons.check, size: 16, color: AppColors.primary),
                label: Text('تم تطبيق الفلترة والتصفية', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  ref.read(studentListControllerProvider.notifier).clearFilter();
                },
                child: const Text('مسح الفلاتر'),
              ),
            ],
          ),
        ],

        const SizedBox(height: 20),

        // Main List Body
        if (state.isLoading) ...[
          LoadingSkeleton.listSkeleton(count: 5),
        ] else if (state.errorMessage != null) ...[
          ErrorStateWidget(
            errorMessage: state.errorMessage!,
            onRetry: () => ref.read(studentListControllerProvider.notifier).fetchStudents(),
          ),
        ] else if (state.result?.students.isEmpty ?? true) ...[
          EmptyStateWidget(
            title: 'لا يوجد طلاب مسجلين',
            message: filter.hasActiveFilters
                ? 'لم يتم العثور على أية سجلات تتطابق مع شروط التصفية والفرز الحالية.'
                : 'قائمة الطلاب فارغة حالياً. يمكنك إضافة أول طالب من خلال نموذج التسجيل العام.',
            actionLabel: filter.hasActiveFilters ? 'مسح الفلاتر' : 'تسجيل طالب جديد',
            onAction: () {
              if (filter.hasActiveFilters) {
                _searchController.clear();
                ref.read(studentListControllerProvider.notifier).clearFilter();
              } else {
                context.go('/registration');
              }
            },
          ),
        ] else ...[
          Expanded(
            child: isDesktop
                ? _buildDesktopTableView(context, state.result!.students)
                : _buildMobileCardView(context, state.result!.students),
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopTableView(BuildContext context, List<Student> students) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
          dataRowMaxHeight: 64,
          columns: const [
            DataColumn(label: Text('المعرف (ID)', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الاسم الكامل', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الجنس', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('المحافظة', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الصف', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('المدرسة', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('المعدل / الدرجة', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الإجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: students.map((student) {
            return DataRow(
              cells: [
                DataCell(Text('#${student.id}')),
                DataCell(
                  Text(
                    student.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                DataCell(Text(AppConstants.getGenderName(student.gender))),
                DataCell(Text(AppConstants.getGovernorateName(student.governorate))),
                DataCell(Text(AppConstants.getClassName(student.classLevel))),
                DataCell(Text(student.schoolName)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: student.grade >= 90
                          ? AppColors.primaryContainer
                          : AppColors.accentContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      student.grade.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: student.grade >= 90 ? AppColors.primaryDark : AppColors.accent,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onPressed: () => context.go('/admin/students/${student.id}'),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileCardView(BuildContext context, List<Student> students) {
    return ListView.separated(
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final student = students[index];
        return CustomCard(
          padding: const EdgeInsets.all(16),
          onTap: () => context.go('/admin/students/${student.id}'),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    student.firstName.isNotEmpty ? student.firstName[0] : '#',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            student.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            student.grade.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${student.schoolName} • ${AppConstants.getClassName(student.classLevel)}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppConstants.getGovernorateName(student.governorate)} • ${AppConstants.getGenderName(student.gender)}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
            ],
          ),
        );
      },
    );
  }
}

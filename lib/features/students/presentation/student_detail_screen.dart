import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/image_lightbox.dart';
import '../../../core/widgets/loading_skeleton.dart';
import 'controllers/student_detail_controller.dart';
import 'controllers/student_list_controller.dart';
import '../domain/student.dart';
import 'widgets/delete_confirm_dialog.dart';
import 'widgets/edit_student_dialog.dart';

class StudentDetailScreen extends ConsumerWidget {
  final int studentId;

  const StudentDetailScreen({super.key, required this.studentId});

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/admin');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentDetailProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'العودة لسجل الطلاب',
          onPressed: () => _goBack(context),
        ),
        title: Text('ملف الطالب #$studentId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث البيانات',
            onPressed: () => ref.invalidate(studentDetailProvider(studentId)),
          ),
        ],
      ),
      body: studentAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: LoadingSkeleton(width: double.infinity, height: 400),
          ),
        ),
        error: (error, stack) => ErrorStateWidget(
          errorMessage: error.toString(),
          onRetry: () => ref.invalidate(studentDetailProvider(studentId)),
        ),
        data: (student) {
          final certUrl = student.formattedImageUrl;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 750;
              final isMobile = constraints.maxWidth < 600;

              final backBar = Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('العودة لسجل الطلاب'),
                    onPressed: () => _goBack(context),
                  ),
                ),
              );

              final headerCard = CustomCard(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: isMobile ? 52 : 64,
                          height: isMobile ? 52 : 64,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              student.firstName.isNotEmpty
                                  ? student.firstName[0]
                                  : '#',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 22 : 28,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.fullName,
                                style:
                                    (isMobile
                                            ? Theme.of(
                                                context,
                                              ).textTheme.titleLarge
                                            : Theme.of(
                                                context,
                                              ).textTheme.headlineSmall)
                                        ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'طالب بصف ${AppConstants.getClassName(student.classLevel)} • ${student.schoolName}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            label: const Text('تعديل البيانات'),
                            onPressed: () async {
                              final updated = await EditStudentDialog.show(
                                context,
                                student,
                              );
                              if (updated == true) {
                                ref.invalidate(
                                  studentDetailProvider(studentId),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            text: 'حذف ',
                            icon: Icons.delete_outline_rounded,
                            variant: AppButtonVariant.danger,
                            onPressed: () async {
                              final deleted = await DeleteConfirmDialog.show(
                                context,
                                student,
                              );
                              if (deleted == true && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'تم حذف بيانات الطالب بنجاح',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: AppColors.success,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                ref.invalidate(studentListControllerProvider);
                                context.go('/admin');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );

              final personalCard = _buildSectionCard(
                context,
                title: '١. البيانات الشخصية',
                icon: Icons.person_rounded,
                children: [
                  _buildDetailRow('المعرف (Student ID)', '#${student.id}'),
                  _buildDetailRow('الاسم الكامل', student.fullName),
                  _buildDetailRow(
                    'الجنس',
                    AppConstants.getGenderName(student.gender),
                  ),
                ],
              );

              final academicCard = _buildSectionCard(
                context,
                title: '٢. البيانات الأكاديمية',
                icon: Icons.school_rounded,
                children: [
                  _buildDetailRow(
                    'المحافظة',
                    AppConstants.getGovernorateName(student.governorate),
                  ),
                  _buildDetailRow(
                    'الصف الدراسي',
                    AppConstants.getClassName(student.classLevel),
                  ),
                  _buildDetailRow('المدرسة', student.schoolName),
                  _buildDetailRow(
                    'المعدل / الدرجة',
                    '${student.grade.toStringAsFixed(1)} %',
                  ),
                ],
              );

              final contactCard = _buildSectionCard(
                context,
                title: '٣. بيانات التواصل',
                icon: Icons.phone_android_rounded,
                children: [
                  _buildDetailRow(
                    'رقم الجوال الأول',
                    student.phone1 ?? 'غير مسجل',
                  ),
                  _buildDetailRow(
                    'رقم الجوال الثاني',
                    student.phone2 ?? 'غير مسجل',
                  ),
                  _buildDetailRow(
                    'العنوان السكني',
                    student.address ?? 'غير مسجل',
                  ),
                ],
              );

              final certCard = _buildCertificateCard(context, student, certUrl);

              return SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 12 : 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 950),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isDesktop) backBar,
                        headerCard,
                        const SizedBox(height: 16),

                        if (isDesktop) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    personalCard,
                                    const SizedBox(height: 16),
                                    certCard,
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  children: [
                                    academicCard,
                                    const SizedBox(height: 16),
                                    contactCard,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          personalCard,
                          const SizedBox(height: 16),
                          academicCard,
                          const SizedBox(height: 16),
                          contactCard,
                          const SizedBox(height: 16),
                          certCard,
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(
    BuildContext context,
    Student student,
    String? certUrl,
  ) {
    final hasUrl = certUrl != null && certUrl.isNotEmpty;

    return CustomCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '٤. صورة الشهادة الدراسية',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 16),
          if (hasUrl) ...[
            GestureDetector(
              onTap: () => ImageLightbox.show(
                context,
                certUrl,
                title: 'شهادة الطالب: ${student.fullName}',
              ),
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  color: AppColors.surfaceVariant,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          certUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_rounded,
                                  size: 48,
                                  color: AppColors.error,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'تعذر تحميل صورة الشهادة من الرابط',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.zoom_in_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'انقر للتكبير والمعاينة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 44,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'لا توجد صورة شهادة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'لم يتم رفع صورة الشهادة الدراسية لهذا الطالب عند التسجيل.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

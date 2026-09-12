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
import 'widgets/delete_confirm_dialog.dart';
import 'widgets/edit_student_dialog.dart';

class StudentDetailScreen extends ConsumerWidget {
  final int studentId;

  const StudentDetailScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentDetailProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: Text('ملف الطالب #$studentId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Top Card
                    CustomCard(
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                student.firstName.isNotEmpty ? student.firstName[0] : '#',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.fullName,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'طالب بصف ${AppConstants.getClassName(student.classLevel)} • ${student.schoolName}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(Icons.edit_rounded, size: 18),
                                label: const Text('تعديل'),
                                onPressed: () => EditStudentDialog.show(context, student),
                              ),
                              const SizedBox(width: 8),
                              AppButton(
                                text: 'حذف',
                                icon: Icons.delete_outline_rounded,
                                variant: AppButtonVariant.danger,
                                onPressed: () async {
                                  final deleted = await DeleteConfirmDialog.show(context, student);
                                  if (deleted == true && context.mounted) {
                                    context.go('/admin');
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Information Grid Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 600;
                        return Column(
                          children: [
                            if (isWide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildAcademicCard(context, student)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildContactCard(context, student)),
                                ],
                              )
                            else ...[
                              _buildAcademicCard(context, student),
                              const SizedBox(height: 16),
                              _buildContactCard(context, student),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Certificate Image Card Section
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified_rounded, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Text(
                                'صورة الشهادة الدراسية',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (student.imageUrl != null && student.imageUrl!.isNotEmpty) ...[
                            GestureDetector(
                              onTap: () => ImageLightbox.show(
                                context,
                                student.imageUrl!,
                                title: 'شهادة الطالب: ${student.fullName}',
                              ),
                              child: Container(
                                height: 260,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Image.network(
                                          student.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Center(
                                            child: Icon(Icons.broken_image, size: 48, color: AppColors.textMuted),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 12,
                                        left: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.7),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.zoom_in, color: Colors.white, size: 16),
                                              SizedBox(width: 6),
                                              Text(
                                                'انقر التكبير والمعاينة',
                                                style: TextStyle(color: Colors.white, fontSize: 12),
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
                              padding: const EdgeInsets.all(32),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.image_not_supported_outlined, size: 48, color: AppColors.textMuted),
                                  SizedBox(height: 8),
                                  Text(
                                    'لا توجد صورة شهادة مرفقة لهذا الطالب',
                                    style: TextStyle(color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAcademicCard(BuildContext context, student) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'البيانات الأكاديمية',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('رقم الطالب', '#${student.id}'),
          _buildInfoRow('المعدل / الدرجة', '${student.grade.toStringAsFixed(1)} %'),
          _buildInfoRow('الصف الدراسي', AppConstants.getClassName(student.classLevel)),
          _buildInfoRow('المدرسة', student.schoolName),
          _buildInfoRow('المحافظة', AppConstants.getGovernorateName(student.governorate)),
          _buildInfoRow('الجنس', AppConstants.getGenderName(student.gender)),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, student) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'بيانات التواصل',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('رقم الجوال الأول', student.phone1 ?? 'غير مسجل'),
          _buildInfoRow('رقم الجوال الثاني', student.phone2 ?? 'غير مسجل'),
          _buildInfoRow('العنوان', student.address ?? 'غير مسجل'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

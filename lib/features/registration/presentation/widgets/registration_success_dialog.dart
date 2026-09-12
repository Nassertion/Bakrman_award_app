import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

class RegistrationSuccessDialog extends StatelessWidget {
  final int studentId;
  final VoidCallback onNewRegistration;

  const RegistrationSuccessDialog({
    super.key,
    required this.studentId,
    required this.onNewRegistration,
  });

  static void show(BuildContext context, int studentId, VoidCallback onNewRegistration) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RegistrationSuccessDialog(
        studentId: studentId,
        onNewRegistration: onNewRegistration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 56,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'تم تقديم طلب التسجيل بنجاح!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'تمت إضافة بياناتك وتحديث سجلات الطالب في النظام بنجاح.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Text(
                    'رقم الطالب المعين (Student ID)',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    '#$studentId',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'تسجيل طالب جديد',
              width: double.infinity,
              onPressed: () {
                Navigator.of(context).pop();
                onNewRegistration();
              },
            ),
          ],
        ),
      ),
    );
  }
}

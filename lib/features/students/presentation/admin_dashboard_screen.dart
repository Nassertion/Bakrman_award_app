import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../auth/presentation/auth_controller.dart';
import 'controllers/student_list_controller.dart';
import 'student_list_screen.dart';
import 'widgets/student_stat_card.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final studentState = ref.watch(studentListControllerProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    // Calculate metrics safely from returned data
    final totalCount = studentState.result?.totalCount ?? 0;
    final students = studentState.result?.students ?? [];
    
    double avgGrade = 0.0;
    int maleCount = 0;
    int femaleCount = 0;
    if (students.isNotEmpty) {
      final totalGrade = students.fold<double>(0.0, (sum, item) => sum + item.grade);
      avgGrade = totalGrade / students.length;
      maleCount = students.where((s) => s.gender.toLowerCase() == 'male').length;
      femaleCount = students.where((s) => s.gender.toLowerCase() == 'female').length;
    }

    final mainContent = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'لوحة التحكم والإدارة',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'أهلاً بك، ${authState.user?.username ?? 'مسؤول النظام'}! مرحباً بك في منظومة إدارة الطلاب.',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('تسجيل طالب جديد'),
                onPressed: () => context.go('/registration'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Statistics Overview Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900
                  ? 4
                  : constraints.maxWidth > 600
                      ? 2
                      : 1;

              if (crossAxisCount == 4) {
                return Row(
                  children: [
                    Expanded(
                      child: StudentStatCard(
                        title: 'إجمالي الطلاب المسجلين',
                        value: '$totalCount',
                        icon: Icons.people_alt_rounded,
                        iconColor: AppColors.primary,
                        containerColor: AppColors.primaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StudentStatCard(
                        title: 'متوسط الدرجات / المعدل',
                        value: avgGrade.toStringAsFixed(1),
                        icon: Icons.auto_graph_rounded,
                        iconColor: AppColors.accent,
                        containerColor: AppColors.accentContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StudentStatCard(
                        title: 'عدد الطلاب (ذكور)',
                        value: '$maleCount',
                        icon: Icons.male_rounded,
                        iconColor: Colors.blue,
                        containerColor: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StudentStatCard(
                        title: 'عدد الطالبات (إناث)',
                        value: '$femaleCount',
                        icon: Icons.female_rounded,
                        iconColor: Colors.pink,
                        containerColor: Colors.pink.withOpacity(0.1),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StudentStatCard(
                          title: 'إجمالي الطلاب',
                          value: '$totalCount',
                          icon: Icons.people_alt_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StudentStatCard(
                          title: 'متوسط المعدل',
                          value: avgGrade.toStringAsFixed(1),
                          icon: Icons.auto_graph_rounded,
                          iconColor: AppColors.accent,
                          containerColor: AppColors.accentContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StudentStatCard(
                          title: 'ذكور',
                          value: '$maleCount',
                          icon: Icons.male_rounded,
                          iconColor: Colors.blue,
                          containerColor: Colors.blue.withOpacity(0.1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StudentStatCard(
                          title: 'إناث',
                          value: '$femaleCount',
                          icon: Icons.female_rounded,
                          iconColor: Colors.pink,
                          containerColor: Colors.pink.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Main Section: Students List Table / Cards
          CustomCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.list_alt_rounded, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      'سجل الطلاب والفرز المتقدم',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const StudentListContent(),
              ],
            ),
          ),
        ],
      ),
    );

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Sidebar Navigation
            Container(
              width: 260,
              color: AppColors.surface,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppConstants.appName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ListTile(
                    leading: const Icon(Icons.dashboard_outlined, color: AppColors.primary),
                    title: const Text('لوحة التحكم', style: TextStyle(fontWeight: FontWeight.bold)),
                    selected: _selectedIndex == 0,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  ListTile(
                    leading: const Icon(Icons.app_registration_outlined),
                    title: const Text('نموذج تسجيل طالب'),
                    onTap: () => context.go('/registration'),
                  ),
                  const Spacer(),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                    title: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                    onTap: () async {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) context.go('/admin/login');
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: mainContent),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/admin/login');
            },
          ),
        ],
      ),
      body: mainContent,
    );
  }
}

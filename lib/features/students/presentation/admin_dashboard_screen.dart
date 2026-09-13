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

    final mainContent = LayoutBuilder(
      builder: (context, screenConstraints) {
        final isMobile = screenConstraints.maxWidth < 600;
        final isNarrowPhone = screenConstraints.maxWidth < 480;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 12 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Layout (Responsive Stack on Mobile, Row on Desktop)
              LayoutBuilder(
                builder: (context, headerConstraints) {
                  final titleColumn = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'لوحة التحكم والإدارة',
                        style: (isMobile
                                ? Theme.of(context).textTheme.titleLarge
                                : Theme.of(context).textTheme.headlineMedium)
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'أهلاً بك، ${authState.user?.username ?? 'مسؤول النظام'}! مرحباً بك في منظومة إدارة الطلاب.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                    ],
                  );

                  final actionButton = ElevatedButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('تسجيل طالب جديد'),
                    onPressed: () => context.go('/admin/registration'),
                  );

                  if (headerConstraints.maxWidth > 600) {
                    return Row(
                      children: [
                        Expanded(child: titleColumn),
                        const SizedBox(width: 16),
                        actionButton,
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      titleColumn,
                      const SizedBox(height: 12),
                      actionButton,
                    ],
                  );
                },
              ),
              SizedBox(height: isMobile ? 16 : 24),

              // Statistics Overview Grid (Responsive 4 -> 2 -> 1)
              LayoutBuilder(
                builder: (context, constraints) {
                  final statCards = [
                    StudentStatCard(
                      title: 'إجمالي الطلاب',
                      value: '$totalCount',
                      icon: Icons.people_alt_rounded,
                      iconColor: AppColors.primary,
                      containerColor: AppColors.primaryContainer,
                    ),
                    StudentStatCard(
                      title: 'متوسط المعدل',
                      value: avgGrade.toStringAsFixed(1),
                      icon: Icons.auto_graph_rounded,
                      iconColor: AppColors.accent,
                      containerColor: AppColors.accentContainer,
                    ),
                    StudentStatCard(
                      title: 'ذكور',
                      value: '$maleCount',
                      icon: Icons.male_rounded,
                      iconColor: Colors.blue,
                      containerColor: Colors.blue.withValues(alpha: 0.1),
                    ),
                    StudentStatCard(
                      title: 'إناث',
                      value: '$femaleCount',
                      icon: Icons.female_rounded,
                      iconColor: Colors.pink,
                      containerColor: Colors.pink.withValues(alpha: 0.1),
                    ),
                  ];

                  if (constraints.maxWidth > 900) {
                    return Row(
                      children: [
                        Expanded(child: statCards[0]),
                        const SizedBox(width: 16),
                        Expanded(child: statCards[1]),
                        const SizedBox(width: 16),
                        Expanded(child: statCards[2]),
                        const SizedBox(width: 16),
                        Expanded(child: statCards[3]),
                      ],
                    );
                  } else if (!isNarrowPhone) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: statCards[0]),
                            const SizedBox(width: 12),
                            Expanded(child: statCards[1]),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: statCards[2]),
                            const SizedBox(width: 12),
                            Expanded(child: statCards[3]),
                          ],
                        ),
                      ],
                    );
                  }

                  // Stack vertically on narrow phones (< 480px) to avoid squeeze/overflow
                  return Column(
                    children: [
                      statCards[0],
                      const SizedBox(height: 10),
                      statCards[1],
                      const SizedBox(height: 10),
                      statCards[2],
                      const SizedBox(height: 10),
                      statCards[3],
                    ],
                  );
                },
              ),
              SizedBox(height: isMobile ? 16 : 32),

              // Main Section: Students List Table / Cards
              CustomCard(
                padding: EdgeInsets.all(isMobile ? 12 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.list_alt_rounded, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'سجل الطلاب والفرز المتقدم',
                            style: (isMobile
                                    ? Theme.of(context).textTheme.titleMedium
                                    : Theme.of(context).textTheme.titleLarge)
                                ?.copyWith(fontWeight: FontWeight.bold),
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
      },
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
                    onTap: () => context.go('/admin/registration'),
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

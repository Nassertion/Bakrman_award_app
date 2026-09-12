import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/admin_login_screen.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/registration/presentation/registration_screen.dart';
import '../../features/students/presentation/admin_dashboard_screen.dart';
import '../../features/students/presentation/student_detail_screen.dart';
import 'auth_change_notifier.dart';

// ─── Single long-lived AuthChangeNotifier ─────────────────────────────────────
// This notifier is kept alive for the entire app lifetime.  GoRouter holds a
// reference to it via [refreshListenable] and re-evaluates redirect logic
// whenever it fires.
final authChangeNotifierProvider = Provider<AuthChangeNotifier>((ref) {
  final notifier = AuthChangeNotifier(ref.read(authControllerProvider));

  // Watch auth state changes and push them into the notifier.
  ref.listen<AuthState>(authControllerProvider, (_, next) {
    notifier.update(next);
  });

  ref.onDispose(notifier.dispose);
  return notifier;
});

// ─── Single long-lived GoRouter ───────────────────────────────────────────────
// GoRouter is created ONCE and reacts to auth changes through [refreshListenable].
// It must NOT be inside a Provider that rebuilds on auth state changes.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authChangeNotifierProvider);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isAuthenticated = authNotifier.authState.isAuthenticated;
      final location = state.uri.toString();

      final isGoingToAdminArea =
          location.startsWith('/admin') && location != '/admin/login';
      final isGoingToLogin = location == '/admin/login';

      if (isGoingToAdminArea && !isAuthenticated) {
        return '/admin/login';
      }
      if (isGoingToLogin && isAuthenticated) {
        return '/admin';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/registration',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/students/:id',
        builder: (context, state) {
          final idParam = state.pathParameters['id'];
          final studentId = int.tryParse(idParam ?? '0') ?? 0;
          return StudentDetailScreen(studentId: studentId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('الصفحة غير موجودة: ${state.uri}'),
      ),
    ),
  );

  return router;
});

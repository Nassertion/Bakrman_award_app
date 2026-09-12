import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/domain/admin_user.dart';

// ─── Re-export AuthState so auth_controller stays the single source ──────────
export '../../../features/auth/domain/admin_user.dart' show AuthState;

/// A [ChangeNotifier] that bridges Riverpod [AuthState] to GoRouter's
/// [refreshListenable].  GoRouter re-evaluates its redirect functions whenever
/// this notifier fires.
class AuthChangeNotifier extends ChangeNotifier {
  AuthState _authState;

  AuthChangeNotifier(this._authState);

  AuthState get authState => _authState;

  void update(AuthState newState) {
    if (newState.isAuthenticated != _authState.isAuthenticated) {
      _authState = newState;
      notifyListeners();
    } else {
      _authState = newState;
    }
  }
}

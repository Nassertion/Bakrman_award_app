import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/auth_storage.dart';
import '../data/auth_repository.dart';
import '../domain/admin_user.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

final authStorageProvider = Provider<AuthStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthStorage(prefs);
});

final Provider<DioClient> dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(authStorageProvider);
  return DioClient(
    authStorage: storage,
    onUnauthorized: () {
      ref.container.read(authControllerProvider.notifier).handleUnauthorized();
    },
  );
});

final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final authStorage = ref.watch(authStorageProvider);
  return AuthRepository(dioClient: dioClient, authStorage: authStorage);
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthState()) {
    state = _repository.checkInitialAuthState();
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final resultState = await _repository.login(username, password);
      state = resultState;
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repository.logout();
    state = const AuthState(isAuthenticated: false);
  }

  void handleUnauthorized() {
    state = const AuthState(
      isAuthenticated: false,
      errorMessage: 'انتهت صلاحية الجلسة، يرجى إعادة تسجيل الدخول.',
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final StateNotifierProvider<AuthController, AuthState> authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});

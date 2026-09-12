import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../app/config/api_config.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/auth_storage.dart';
import '../domain/admin_user.dart';

class AuthRepository {
  final DioClient dioClient;
  final AuthStorage authStorage;

  AuthRepository({
    required this.dioClient,
    required this.authStorage,
  });

  /// Performs a real POST /admin/login and validates the token by calling
  /// GET /admin/students.  No fallback, no mock, no test mode.
  Future<AuthState> login(String username, String password) async {
    // ── Step 1: POST /admin/login ──────────────────────────────────────────
    final loginUrl = '${ApiConfig.baseUrl}${ApiConfig.adminLogin}';
    debugPrint('[AUTH] → POST $loginUrl');
    debugPrint('[AUTH]   username: $username');
    // password intentionally NOT logged.

    Response<dynamic> loginResponse;
    try {
      final formData = FormData.fromMap({
        'username': username,
        'password': password,
      });

      loginResponse = await dioClient.dio.post(
        ApiConfig.adminLogin,
        data: formData,
      );
    } catch (e) {
      debugPrint('[AUTH] ✗ Login request failed: $e');
      throw ErrorHandler.handle(e);
    }

    debugPrint('[AUTH]   HTTP status: ${loginResponse.statusCode}');

    // ── Step 2: Parse the real backend response ───────────────────────────
    //
    // Actual response shape (HTTP 200):
    //   {
    //     "message":      "Login successful",
    //     "access_token": "<token>",
    //     "token_type":   "Bearer",
    //     "user":         { "id": 1, "username": "admin", ... }
    //   }
    //
    // Requirements:
    //  • HTTP 200 + non-empty access_token  → success
    //  • No "success" field required
    //  • No nested "data" object
    final data = loginResponse.data;

    if (data is! Map<String, dynamic>) {
      debugPrint('[AUTH] ✗ Response is not a JSON object (type: ${loginResponse.data.runtimeType})');
      throw const ApiException(
        message: 'استجابة غير صالحة من الخادم (ليست JSON).',
      );
    }

    debugPrint('[AUTH]   Response keys: ${data.keys.toList()}');

    // Read access_token from the flat top-level object.
    final String? token = data['access_token']?.toString();
    if (token == null || token.trim().isEmpty) {
      // Surface the backend's own message if present.
      final backendMessage = data['message']?.toString() ??
          'لم يتم استلام رمز المصادقة من الخادم.';
      debugPrint('[AUTH] ✗ access_token absent or empty — $backendMessage');
      throw ApiException(message: backendMessage);
    }

    // Log only the first 12 chars of the token; never log the full value.
    final tokenPreview =
        token.length > 12 ? '${token.substring(0, 12)}…' : token;
    debugPrint('[AUTH]   access_token received: $tokenPreview');

    // Read user from the flat top-level object.
    final userData = data['user'];
    if (userData is! Map<String, dynamic>) {
      debugPrint('[AUTH] ✗ Missing or invalid "user" field in response');
      throw const ApiException(
        message: 'بيانات المستخدم غير موجودة في استجابة الخادم.',
      );
    }

    final AdminUser user;
    try {
      user = AdminUser.fromJson(userData);
    } catch (e) {
      debugPrint('[AUTH] ✗ Failed to parse user object: $e');
      throw const ApiException(
        message: 'تعذر قراءة بيانات المستخدم من الخادم.',
      );
    }

    debugPrint('[AUTH]   User id=${user.id}, username=${user.username}');

    // ── Step 3: Persist token so the Dio interceptor can inject it ────────
    await authStorage.saveToken(token);
    await authStorage.saveUser(user.toJson());

    // ── Step 4: Verify token is accepted by GET /admin/students ──────────
    debugPrint('[AUTH] → GET ${ApiConfig.baseUrl}${ApiConfig.adminStudents} (token verification)');
    try {
      final verifyResponse = await dioClient.dio.get(
        ApiConfig.adminStudents,
        queryParameters: {'page': 1, 'per_page': 1},
      );
      debugPrint('[AUTH]   Verification HTTP status: ${verifyResponse.statusCode}');
      if ((verifyResponse.statusCode ?? 0) == 401) {
        debugPrint('[AUTH] ✗ Token rejected by server (401)');
        await authStorage.clearAuth();
        throw const ApiException(
          message: 'رمز المصادقة مرفوض من الخادم. يرجى تسجيل الدخول مجدداً.',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        debugPrint('[AUTH] ✗ Token verification returned 401 — treating as failed login');
        await authStorage.clearAuth();
        throw const ApiException(
          message: 'رمز المصادقة مرفوض من الخادم. يرجى تسجيل الدخول مجدداً.',
        );
      }
      // Non-401 network errors during verification are logged but not fatal
      // (e.g. momentary connectivity loss after a valid login).
      debugPrint('[AUTH] ⚠ Token verification network error (non-401): ${e.type} — proceeding');
    } catch (e) {
      debugPrint('[AUTH] ⚠ Unexpected error during token verification: $e — proceeding');
    }

    debugPrint('[AUTH] ✓ Login complete — user ${user.username} authenticated');

    return AuthState(
      isAuthenticated: true,
      token: token,
      user: user,
    );
  }

  Future<void> logout() async {
    try {
      await dioClient.dio.post(ApiConfig.logout);
    } catch (_) {
      // Clean local token regardless of network failure during logout.
    } finally {
      await authStorage.clearAuth();
    }
  }

  AuthState checkInitialAuthState() {
    if (authStorage.isAuthenticated()) {
      final token = authStorage.getToken();
      final userMap = authStorage.getUser();
      final user = userMap != null ? AdminUser.fromJson(userMap) : null;
      debugPrint('[AUTH] Restored session: user=${user?.username}, token present=${token != null}');
      return AuthState(
        isAuthenticated: true,
        token: token,
        user: user,
      );
    }
    return const AuthState(isAuthenticated: false);
  }
}

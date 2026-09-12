import 'package:dio/dio.dart';
import '../../app/config/api_config.dart';
import '../storage/auth_storage.dart';

class DioClient {
  late final Dio dio;
  final AuthStorage authStorage;
  Function()? onUnauthorized;

  DioClient({
    required this.authStorage,
    this.onUnauthorized,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = authStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await authStorage.clearAuth();
            if (onUnauthorized != null) {
              onUnauthorized!();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}

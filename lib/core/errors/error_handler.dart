import 'package:dio/dio.dart';
import 'api_exception.dart';

class ErrorHandler {
  static ApiException handle(dynamic error) {
    if (error is ApiException) {
      return error;
    }

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException(
            message: 'انتهت مهلة الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت والإعادة.',
          );

        case DioExceptionType.connectionError:
          return ApiException(
            message: 'فشل الاتصال بالشبكة. يرجى التأكد من اتصال الجهاز بالإنترنت.',
          );

        case DioExceptionType.badResponse:
          final response = error.response;
          if (response != null) {
            return parseResponseError(response.statusCode, response.data);
          }
          return ApiException(message: 'حدث خطأ غير متوقع من الخادم.');

        case DioExceptionType.cancel:
          return ApiException(message: 'تم إلغاء الطلب.');

        default:
          return ApiException(
            message: error.message ?? 'حدث خطأ غير متوقع بالشبكة.',
          );
      }
    }

    return ApiException(message: error.toString());
  }

  static ApiException parseResponseError(int? statusCode, dynamic data) {
    String message = 'حدث خطأ أثناء معالجة الطلب.';
    Map<String, List<String>>? fieldErrors;

    if (data is Map<String, dynamic>) {
      if (data.containsKey('message') && data['message'] != null) {
        message = data['message'].toString();
      }

      if (data.containsKey('errors') && data['errors'] is Map) {
        fieldErrors = {};
        final rawErrors = data['errors'] as Map<String, dynamic>;
        rawErrors.forEach((key, value) {
          if (value is List) {
            fieldErrors![key] = value.map((e) => e.toString()).toList();
          } else if (value != null) {
            fieldErrors![key] = [value.toString()];
          }
        });
      }
    }

    // Specific HTTP Status overrides for Arabic feedback
    if (statusCode == 401) {
      message = 'اسم المستخدم أو كلمة المرور غير صحيحة، أو انقضت جلسة التسجيل.';
    } else if (statusCode == 403) {
      message = 'ليس لديك الصلاحيات الكافية لتنفيذ هذا الإجراء.';
    } else if (statusCode == 404) {
      message = 'العنصر المطلوب غير موجود أو تم حذفه.';
    } else if (statusCode == 422 && fieldErrors != null && fieldErrors.isNotEmpty) {
      message = 'يرجى مراجعة البيانات المدخلة وتصحيح الأخطاء.';
    } else if (statusCode != null && statusCode >= 500) {
      message = 'حدث خطأ داخلي في الخادم ($statusCode). يرجى المحاولة لاحقاً.';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      fieldErrors: fieldErrors,
    );
  }
}

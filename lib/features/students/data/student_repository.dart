import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../app/config/api_config.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../domain/pagination_meta.dart';
import '../domain/student.dart';
import '../domain/student_filter.dart';

class StudentRepository {
  final DioClient dioClient;

  StudentRepository(this.dioClient);

  Future<PaginatedStudentsResult> getStudents(StudentFilter filter) async {
    try {
      final response = await dioClient.dio.get(
        ApiConfig.adminStudents,
        queryParameters: filter.toApiParams(),
      );

      final data = response.data;
      final status = response.statusCode;
      final topKeys = data is Map ? data.keys.join(', ') : 'N/A (not a map)';
      final hasDataKey = data is Map ? data.containsKey('data') : false;
      final dataType = data?.runtimeType.toString() ?? 'null';

      final result = PaginatedStudentsResult.fromApiResponse(data);

      debugPrint(
        '[StudentsAPI] GET ${ApiConfig.adminStudents} | Status: $status | TopKeys: [$topKeys] | HasDataKey: $hasDataKey | DataType: $dataType | Count: ${result.students.length}',
      );

      return result;
    } catch (e) {
      debugPrint('[StudentsAPI] GET ${ApiConfig.adminStudents} Error: $e');
      throw ErrorHandler.handle(e);
    }
  }

  Future<Student> getStudent(int id) async {
    try {
      final response = await dioClient.dio.get(ApiConfig.adminStudentById(id));
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        final studentMap = data['data'] as Map<String, dynamic>;
        return Student.fromJson(studentMap);
      }
      throw ErrorHandler.parseResponseError(response.statusCode, data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<bool> updateStudent(int id, Map<String, dynamic> updatedFields) async {
    try {
      final response = await dioClient.dio.put(
        ApiConfig.adminStudentById(id),
        data: updatedFields,
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        return true;
      }
      return true;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<bool> deleteStudent(int id) async {
    try {
      final response = await dioClient.dio.delete(ApiConfig.adminStudentById(id));
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        return true;
      }
      return true;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<dynamic> exportCsv(StudentFilter filter) async {
    try {
      final response = await dioClient.dio.get(
        ApiConfig.adminExportCsv,
        queryParameters: filter.toCsvParams(),
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}

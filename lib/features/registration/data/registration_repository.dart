import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import '../../../app/config/api_config.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/network/dio_client.dart';

class RegistrationRepository {
  final DioClient dioClient;

  RegistrationRepository(this.dioClient);

  Future<int> submitStudentRegistration({
    required String firstName,
    required String secondName,
    required String thirdName,
    required String lastName,
    required String gender,
    required int governorate,
    required int classLevel,
    required String schoolName,
    required double grade,
    required XFile certImage,
    List<XFile>? additionalImages,
    String? phone1,
    String? phone2,
    String? address,
  }) async {
    try {
      final map = <String, dynamic>{
        'first_name': firstName,
        'second_name': secondName,
        'third_name': thirdName,
        'last_name': lastName,
        'gender': gender,
        'governorate': governorate,
        'class': classLevel,
        'school_name': schoolName,
        'grade': grade,
      };

      if (phone1 != null && phone1.isNotEmpty) map['phone1'] = phone1;
      if (phone2 != null && phone2.isNotEmpty) map['phone2'] = phone2;
      if (address != null && address.isNotEmpty) map['address'] = address;

      // Handle main cert image
      final certBytes = await certImage.readAsBytes();
      map['cert_image'] = MultipartFile.fromBytes(
        certBytes,
        filename: certImage.name.isNotEmpty ? certImage.name : 'cert_image.jpg',
      );

      // Handle optional additional images
      if (additionalImages != null && additionalImages.isNotEmpty) {
        for (int i = 0; i < additionalImages.length; i++) {
          final file = additionalImages[i];
          final bytes = await file.readAsBytes();
          map['additional_images[$i]'] = MultipartFile.fromBytes(
            bytes,
            filename: file.name.isNotEmpty ? file.name : 'image_$i.jpg',
          );
        }
      }

      final formData = FormData.fromMap(map);
      final response = await dioClient.dio.post(
        ApiConfig.publicStudents,
        data: formData,
      );

      final responseData = response.data;
      final status = response.statusCode ?? 200;
      if (status >= 200 && status < 300) {
        int studentId = 0;
        if (responseData is Map) {
          final mapData = Map<String, dynamic>.from(responseData);
          if (mapData['data'] is Map && mapData['data']['id'] != null) {
            studentId = int.tryParse(mapData['data']['id'].toString()) ?? 0;
          } else if (mapData['id'] != null) {
            studentId = int.tryParse(mapData['id'].toString()) ?? 0;
          } else if (mapData['student'] is Map && mapData['student']['id'] != null) {
            studentId = int.tryParse(mapData['student']['id'].toString()) ?? 0;
          }
        }
        return studentId;
      }
      throw ErrorHandler.parseResponseError(status, responseData);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}

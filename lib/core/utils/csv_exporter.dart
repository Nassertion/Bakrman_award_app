import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

// Conditional imports for Web vs Mobile
import 'csv_exporter_web.dart' if (dart.library.io) 'csv_exporter_mobile.dart';

abstract class CsvExporter {
  static Future<bool> saveAndShareCsv(dynamic csvData, String fileName) async {
    List<int> bytes;
    if (csvData is String) {
      bytes = utf8.encode(csvData);
    } else if (csvData is List<int>) {
      bytes = csvData;
    } else if (csvData is Uint8List) {
      bytes = csvData;
    } else {
      throw Exception('بيانات CSV غير صالحة');
    }

    return exportCsvBytes(Uint8List.fromList(bytes), fileName);
  }
}

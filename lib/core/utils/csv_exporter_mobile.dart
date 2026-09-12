import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<bool> exportCsvBytes(Uint8List bytes, String fileName) async {
  try {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      directory = await getTemporaryDirectory();
    }

    final path = '${directory.path}/$fileName${fileName.endsWith('.csv') ? '' : '.csv'}';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return true;
  } catch (e) {
    return false;
  }
}

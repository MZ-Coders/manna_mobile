import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {

  Directory? directory;

  if (Platform.isAndroid) {
    directory = await getExternalStorageDirectory(); // Apenas Android
  } else if (Platform.isIOS) {
    directory = await getApplicationDocumentsDirectory(); // iOS
  } else {
    throw UnsupportedError("Plataforma não suportada");
  }

  final path = directory?.path;
  final file = File('$path/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  OpenFile.open('$path/$fileName');
}
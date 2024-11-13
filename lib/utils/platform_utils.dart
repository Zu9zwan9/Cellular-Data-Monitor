import 'dart:io' show Platform;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<String> getApplicationDocumentsDirectoryPath() async {
  if (kIsWeb) {
    // Handle web-specific logic here
    return '/';
  } else if (Platform.isAndroid || Platform.isIOS) {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  } else {
    throw UnsupportedError('Unsupported platform');
  }
}

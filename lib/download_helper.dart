import 'download_stub.dart'
if (dart.library.html) 'download_web.dart'
if (dart.library.io) 'download_mobile.dart';

class DownloadHelper {
  static Future<void> downloadAsset(String assetPath, String fileName) async {
    // This calls the saveFile function which is defined in the files below
    await saveFile(assetPath, fileName);
  }
}
import 'dart:html' as html;
import 'package:flutter/services.dart';

Future<void> saveFile(String assetPath, String fileName) async {
  final bytes = await rootBundle.load(assetPath);
  final blob = html.Blob([bytes.buffer.asUint8List()]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
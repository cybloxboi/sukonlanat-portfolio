import 'package:web/web.dart' as web;

const supportsImageDownload = true;

Future<void> downloadImage(String url, String fileName) async {
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = fileName;
  anchor.click();
}

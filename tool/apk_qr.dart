// Writes a QR code for a URL as an SVG, for the README's download section.
//
// Usage: dart run tool/apk_qr.dart <url> <output.svg>
import 'dart:io';

import 'package:qr/qr.dart';

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('Usage: dart run tool/apk_qr.dart <url> <output.svg>');
    exit(64);
  }
  final url = args[0];
  final output = File(args[1]);

  // High error correction keeps the code readable from a screen or a photo.
  final image = QrImage(
    QrCode.fromData(data: url, errorCorrectLevel: QrErrorCorrectLevel.H),
  );

  const quietZone = 4;
  const moduleSize = 8;
  final size = (image.moduleCount + quietZone * 2) * moduleSize;

  final path = StringBuffer();
  for (var row = 0; row < image.moduleCount; row++) {
    for (var col = 0; col < image.moduleCount; col++) {
      if (!image.isDark(row, col)) continue;
      final x = (col + quietZone) * moduleSize;
      final y = (row + quietZone) * moduleSize;
      path.write('M$x ${y}h${moduleSize}v${moduleSize}h-${moduleSize}z');
    }
  }

  output
    ..createSync(recursive: true)
    ..writeAsStringSync(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $size $size" '
      'width="$size" height="$size" shape-rendering="crispEdges">'
      '<title>Download the Android APK: $url</title>'
      '<rect width="100%" height="100%" fill="#ffffff"/>'
      '<path fill="#101628" d="$path"/>'
      '</svg>\n',
    );
  stdout.writeln('Wrote ${output.path} (${image.moduleCount} modules) for $url');
}

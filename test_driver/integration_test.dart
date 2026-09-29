import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Host-side driver: saves screenshots taken by the integration test.
Future<void> main() {
  return integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File('docs/screenshots/$name.png');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}

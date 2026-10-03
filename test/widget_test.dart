import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:pos/main.dart';

void main() {
  for (final size in [
    Size(800, 600), // small Chrome debug window
    Size(1024, 600), // small 7" tablet, landscape
    Size(1280, 800), // common Android tablet, landscape
    Size(1920, 1200), // large tablet, landscape
    Size(600, 960), // narrow fallback (portrait)
  ]) {
    testWidgets('Login screen renders without overflow at $size', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const UltimaPosApp());

      expect(tester.takeException(), isNull);
      expect(find.text('Selamat Datang'), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);
    });
  }
}

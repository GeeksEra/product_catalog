import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/screens/qr_viewer/qr_viewer_screen.dart';
import 'package:product_catalog/theme/app_theme.dart';
import 'package:product_catalog/widgets/qr_code_card.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('tapping a code asks to open it full screen', (tester) async {
    QrSource? opened;
    await tester.pumpWidget(
      wrap(
        QrCodeCard(
          qrCodeUrl: null,
          qrData: '5784719087687',
          onOpen: (source) => opened = source,
        ),
      ),
    );

    await tester.tap(find.text('Generated'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(opened, QrSource.generated);
    expect(find.text('Tap a code to scan it full screen'), findsOneWidget);
  });

  testWidgets('the viewer shows the code, product and barcode, and closes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const QrViewerScreen(
                  source: QrSource.generated,
                  data: '5784719087687',
                  productTitle: 'Desk Lamp',
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('QR code for 5784719087687'), findsOneWidget);
    expect(find.text('Desk Lamp'), findsOneWidget);
    expect(find.text('Barcode 5784719087687'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
  });
}

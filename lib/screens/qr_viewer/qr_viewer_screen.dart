import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dimens.dart';
import 'package:product_catalog/theme/light_colors.dart';
import 'package:product_catalog/widgets/qr_code_card.dart';

/// One QR code, as large as the screen allows, for scanning.
///
/// It always uses the light palette: a white field with dark modules scans
/// most reliably, in either app theme. Tap anywhere or Close to go back.
class QrViewerScreen extends StatelessWidget {
  const QrViewerScreen({
    required this.source,
    required this.data,
    required this.productTitle,
    this.url,
    super.key,
  });

  final QrSource source;
  final String data;
  final String productTitle;

  /// The image URL, for [QrSource.api].
  final String? url;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final codeSize = math.min(size.width, size.height) * 0.78;
    final label = source == QrSource.api
        ? 'QR code from the API'
        : 'Barcode $data';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Material(
        color: lightColors.background,
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Dimens.space24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Hero(
                          tag: qrHeroTag(source, data),
                          child: SizedBox.square(
                            dimension: codeSize,
                            child: ProductQr(
                              source: source,
                              data: data,
                              url: url,
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimens.space24),
                        Text(
                          productTitle,
                          textAlign: TextAlign.center,
                          style: AppText.headingMedium(color: lightColors.text),
                        ),
                        const SizedBox(height: Dimens.space4),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: AppText.bodyMedium(
                            color: lightColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: Dimens.space16),
                        Text(
                          'Point a camera at the code to scan it',
                          textAlign: TextAlign.center,
                          style: AppText.labelMedium(
                            color: lightColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: Dimens.space4,
                  right: Dimens.space4,
                  child: IconButton(
                    tooltip: 'Close',
                    color: lightColors.text,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

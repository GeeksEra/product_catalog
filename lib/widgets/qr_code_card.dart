import 'package:flutter/material.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dimens.dart';
import 'package:product_catalog/theme/light_colors.dart';
import 'package:product_catalog/widgets/app_network_image.dart';
import 'package:product_catalog/widgets/scale_tap.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Where a QR code comes from.
enum QrSource {
  /// The `meta.qrCode` image from the API.
  api,

  /// Generated on the device from the product's barcode.
  generated,
}

/// Hero tag shared by a QR tile and its full-screen view.
String qrHeroTag(QrSource source, String data) => 'qr-${source.name}-$data';

/// Shows the product's QR codes. Tapping one calls [onOpen] so the screen can
/// show it full screen for scanning.
///
/// The left tile is the `meta.qrCode` image from the API. DummyJSON returns
/// the same placeholder for every product, so the right tile is a real QR
/// code generated on the device from the barcode.
class QrCodeCard extends StatelessWidget {
  const QrCodeCard({
    required this.qrCodeUrl,
    required this.qrData,
    required this.onOpen,
    super.key,
  });

  final String? qrCodeUrl;
  final String qrData;
  final ValueChanged<QrSource> onOpen;

  static const double _codeSize = 120;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = qrCodeUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimens.space16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Dimens.radiusMedium),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: Dimens.space16,
            runSpacing: Dimens.space16,
            children: [
              if (url != null)
                _QrTile(
                  caption: 'From API',
                  heroTag: qrHeroTag(QrSource.api, qrData),
                  onTap: () => onOpen(QrSource.api),
                  child: ProductQr(
                    source: QrSource.api,
                    data: qrData,
                    url: url,
                  ),
                ),
              _QrTile(
                caption: 'Generated',
                heroTag: qrHeroTag(QrSource.generated, qrData),
                onTap: () => onOpen(QrSource.generated),
                child: ProductQr(source: QrSource.generated, data: qrData),
              ),
            ],
          ),
          const SizedBox(height: Dimens.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fullscreen_rounded,
                size: Dimens.iconSmall,
                color: colors.textTertiary,
              ),
              const SizedBox(width: Dimens.space4),
              Text(
                'Tap a code to scan it full screen',
                style: AppText.labelSmall(color: colors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The QR code itself, on a light field.
///
/// Scanners need dark modules on a light background, so the code keeps the
/// light palette in dark mode too.
class ProductQr extends StatelessWidget {
  const ProductQr({
    required this.source,
    required this.data,
    this.url,
    super.key,
  }) : assert(source != QrSource.api || url != null);

  final QrSource source;
  final String data;

  /// The image URL, for [QrSource.api].
  final String? url;

  @override
  Widget build(BuildContext context) {
    return switch (source) {
      QrSource.api => AppNetworkImage(url: url!, fit: BoxFit.contain),
      QrSource.generated => QrImageView(
        data: data,
        padding: EdgeInsets.zero,
        semanticsLabel: 'QR code for $data',
        backgroundColor: lightColors.background,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: lightColors.text,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: lightColors.text,
        ),
      ),
    };
  }
}

class _QrTile extends StatelessWidget {
  const _QrTile({
    required this.caption,
    required this.heroTag,
    required this.onTap,
    required this.child,
  });

  final String caption;
  final Object heroTag;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: '$caption QR code. Double tap to show it full screen.',
      excludeSemantics: true,
      child: ScaleTap(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: heroTag,
              child: Container(
                width: QrCodeCard._codeSize,
                height: QrCodeCard._codeSize,
                padding: const EdgeInsets.all(Dimens.space8),
                decoration: BoxDecoration(
                  color: lightColors.background,
                  borderRadius: BorderRadius.circular(Dimens.radiusSmall),
                ),
                child: child,
              ),
            ),
            const SizedBox(height: Dimens.space8),
            Text(
              caption,
              style: AppText.labelSmall(color: colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

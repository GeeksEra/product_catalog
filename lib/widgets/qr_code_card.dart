import 'package:flutter/material.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dimens.dart';
import 'package:product_catalog/theme/light_colors.dart';
import 'package:product_catalog/widgets/app_network_image.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Shows the product's QR code.
///
/// The left tile is the `meta.qrCode` image from the API. DummyJSON returns
/// the same placeholder for every product, so the right tile is a real QR
/// code generated on the device from the barcode.
class QrCodeCard extends StatelessWidget {
  const QrCodeCard({required this.qrCodeUrl, required this.qrData, super.key});

  final String? qrCodeUrl;
  final String qrData;

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
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: Dimens.space16,
        runSpacing: Dimens.space16,
        children: [
          if (url != null)
            _QrTile(
              caption: 'From API',
              child: AppNetworkImage(url: url, fit: BoxFit.contain),
            ),
          _QrTile(
            caption: 'Generated',
            child: QrImageView(
              data: qrData,
              padding: EdgeInsets.zero,
              semanticsLabel: 'QR code for $qrData',
              // Scanners need dark modules on a light field, so the code keeps
              // the light palette in dark mode too.
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
          ),
        ],
      ),
    );
  }
}

class _QrTile extends StatelessWidget {
  const _QrTile({required this.caption, required this.child});

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: QrCodeCard._codeSize,
          height: QrCodeCard._codeSize,
          padding: const EdgeInsets.all(Dimens.space8),
          decoration: BoxDecoration(
            color: lightColors.background,
            borderRadius: BorderRadius.circular(Dimens.radiusSmall),
          ),
          child: child,
        ),
        const SizedBox(height: Dimens.space8),
        Text(caption, style: AppText.labelSmall(color: colors.textTertiary)),
      ],
    );
  }
}

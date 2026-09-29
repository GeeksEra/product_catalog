import 'package:flutter/material.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dimens.dart';
import 'package:product_catalog/widgets/app_network_image.dart';

/// Full-screen, pinch-to-zoom viewer for product images.
class ImageViewerScreen extends StatefulWidget {
  const ImageViewerScreen({
    required this.images,
    this.initialIndex = 0,
    super.key,
  });

  final List<String> images;
  final int initialIndex;

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _page = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Content on the black media scrim uses the on-primary token, which is
    // white in both themes.
    final foreground = context.colors.buttonPrimaryText;

    return Scaffold(
      // A black scrim behind media is the one allowed use of raw colors.
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (_, index) => InteractiveViewer(
              maxScale: 4,
              child: Center(
                child: AppNetworkImage(
                  url: widget.images[index],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimens.space4),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Close',
                    color: foreground,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  if (widget.images.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(right: Dimens.space12),
                      child: Text(
                        '${_page + 1} / ${widget.images.length}',
                        style: AppText.labelLarge(color: foreground),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

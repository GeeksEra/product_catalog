import 'package:flutter/material.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/dimens.dart';
import 'package:product_catalog/widgets/app_network_image.dart';

/// A swipeable image gallery with page dots.
///
/// It is square unless [expand] is set, in which case it fills its parent (the
/// detail screen's collapsing header). The first image carries [heroTag] so
/// the list thumbnail flies into it. Tapping an image calls [onImageTap] with
/// its index.
class ImageGallery extends StatefulWidget {
  const ImageGallery({
    required this.images,
    required this.heroTag,
    required this.onImageTap,
    this.placeholderUrl,
    this.expand = false,
    this.imagePadding = const EdgeInsets.all(Dimens.space24),
    super.key,
  });

  final List<String> images;
  final Object heroTag;
  final ValueChanged<int> onImageTap;

  /// Shown while the first image loads. See [AppNetworkImage.placeholderUrl].
  final String? placeholderUrl;

  final bool expand;

  /// Space around each image, so it clears overlaid controls.
  final EdgeInsets imagePadding;

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void didUpdateWidget(ImageGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_page >= widget.images.length) _page = 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final colors = context.colors;

    final gallery = ColoredBox(
      color: colors.surfaceHighlight,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) {
              Widget image = AppNetworkImage(
                url: images[index],
                fit: BoxFit.contain,
                placeholderUrl: index == 0 ? widget.placeholderUrl : null,
              );
              image = Padding(padding: widget.imagePadding, child: image);
              if (index == 0) {
                image = Hero(tag: widget.heroTag, child: image);
              }
              return Semantics(
                image: true,
                button: true,
                label:
                    'Image ${index + 1} of ${images.length}. '
                    'Double tap to view full screen.',
                child: GestureDetector(
                  onTap: () => widget.onImageTap(index),
                  child: image,
                ),
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: Dimens.space16,
              child: PageDots(count: images.length, current: _page),
            ),
        ],
      ),
    );
    return widget.expand
        ? gallery
        : AspectRatio(aspectRatio: 1, child: gallery);
  }
}

/// A row of dots with the current one widened.
class PageDots extends StatelessWidget {
  const PageDots({required this.count, required this.current, super.key});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: Dimens.space2),
              width: i == current ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == current ? colors.text : colors.borderSecondary,
                borderRadius: BorderRadius.circular(Dimens.radiusPill),
              ),
            ),
        ],
      ),
    );
  }
}

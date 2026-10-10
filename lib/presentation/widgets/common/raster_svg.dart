import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'svg_raster_cache.dart';

/// Square SVG asset drawn from a cached bitmap rather than replayed as
/// vectors on every frame. Use it for every game icon.
///
/// Greying and fading stay a single plain image draw: the greyscale variant
/// is its own cached bitmap and the opacity only modulates the paint, so
/// neither needs a compositing layer.
class RasterSvg extends StatefulWidget {
  final String assetPath;
  final double size;

  /// Draws the greyscale bitmap of the asset, e.g. for a locked item.
  final bool greyscale;

  /// Alpha applied while drawing the bitmap, from 0 (hidden) to 1 (opaque).
  final double opacity;

  /// Optional tint blended over the icon, e.g. a greyed-out silhouette.
  final Color? color;
  final BlendMode colorBlendMode;

  const RasterSvg({
    super.key,
    required this.assetPath,
    this.size = 24,
    this.greyscale = false,
    this.opacity = 1,
    this.color,
    this.colorBlendMode = BlendMode.srcIn,
  });

  @override
  State<RasterSvg> createState() => _RasterSvgState();
}

class _RasterSvgState extends State<RasterSvg> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(RasterSvg oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath ||
        oldWidget.greyscale != widget.greyscale) {
      _resolve();
    }
  }

  /// Icons are normally preloaded at startup and drawn on the first frame;
  /// any other bitmap is derived once, then shown.
  void _resolve() {
    final path = widget.assetPath;
    final grey = widget.greyscale;
    _image = grey ? SvgRasterCache.peekGrey(path) : SvgRasterCache.peek(path);
    if (_image != null) return;
    final load = grey ? SvgRasterCache.loadGrey : SvgRasterCache.load;
    load(path).then((image) {
      if (mounted && widget.assetPath == path && widget.greyscale == grey) {
        setState(() => _image = image);
      }
    }, onError: (Object _) {});
  }

  @override
  Widget build(BuildContext context) {
    final opacity = widget.opacity;
    return SizedBox.square(
      dimension: widget.size,
      child: RawImage(
        image: _image,
        width: widget.size,
        height: widget.size,
        filterQuality: FilterQuality.medium,
        opacity: opacity < 1 ? AlwaysStoppedAnimation<double>(opacity) : null,
        color: widget.color,
        colorBlendMode: widget.colorBlendMode,
      ),
    );
  }
}

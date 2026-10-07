import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'svg_raster_cache.dart';

/// Square SVG asset drawn from a cached bitmap rather than replayed as
/// vectors on every frame. Use it for every game icon.
class RasterSvg extends StatefulWidget {
  final String assetPath;
  final double size;

  /// Optional tint blended over the icon, e.g. a greyed-out silhouette.
  final Color? color;
  final BlendMode colorBlendMode;

  const RasterSvg({
    super.key,
    required this.assetPath,
    this.size = 24,
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
    if (oldWidget.assetPath != widget.assetPath) _resolve();
  }

  /// Icons are normally preloaded at startup and drawn on the first frame;
  /// any other asset is rasterized once, then shown.
  void _resolve() {
    final path = widget.assetPath;
    _image = SvgRasterCache.peek(path);
    if (_image != null) return;
    SvgRasterCache.load(path).then((image) {
      if (mounted && widget.assetPath == path) {
        setState(() => _image = image);
      }
    }, onError: (Object _) {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: RawImage(
        image: _image,
        width: widget.size,
        height: widget.size,
        filterQuality: FilterQuality.medium,
        color: widget.color,
        colorBlendMode: widget.colorBlendMode,
      ),
    );
  }
}

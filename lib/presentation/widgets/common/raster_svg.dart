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
  (String, int)? _key;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(RasterSvg oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resolve();
  }

  void _resolve() {
    final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    final key = (
      widget.assetPath,
      SvgRasterCache.pixelsFor(widget.size, ratio),
    );
    if (key == _key) return;
    _key = key;
    _image = SvgRasterCache.peek(key.$1, key.$2);
    if (_image != null) return;
    SvgRasterCache.load(key.$1, key.$2).then((image) {
      if (mounted && _key == key) setState(() => _image = image);
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

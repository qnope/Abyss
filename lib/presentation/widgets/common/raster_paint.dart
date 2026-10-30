import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'painted_raster.dart';

/// Paints a still [painter] from a bitmap rasterized once (see
/// [PaintedRaster]), [repeat] times side by side across its box: each
/// copy is the painter at its share of the box's width.
///
/// Rasterizes again only when the painter asks to repaint, or the box or
/// [resolution] (pixels per logical pixel, the device's by default)
/// changes; the bitmap lives as long as the widget's render object,
/// drawn with [filterQuality]. Rasterizes in the background, never
/// holding a frame: the painting is replayed live until the bitmap is
/// ready. Fills its box.
class RasterPaint extends LeafRenderObjectWidget {
  final CustomPainter painter;
  final int repeat;
  final double? resolution;
  final FilterQuality filterQuality;

  const RasterPaint({
    super.key,
    required this.painter,
    this.repeat = 1,
    this.resolution,
    this.filterQuality = FilterQuality.low,
  });

  double _resolutionIn(BuildContext context) =>
      resolution ?? MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;

  @override
  RenderRasterPaint createRenderObject(BuildContext context) =>
      RenderRasterPaint(painter, repeat, _resolutionIn(context))
        ..filterQuality = filterQuality;

  @override
  void updateRenderObject(
      BuildContext context, RenderRasterPaint renderObject) {
    renderObject
      ..painter = painter
      ..repeat = repeat
      ..resolution = _resolutionIn(context)
      ..filterQuality = filterQuality;
  }
}

/// The render object of a [RasterPaint], keeping its bitmap.
class RenderRasterPaint extends RenderBox {
  CustomPainter _painter;
  int _repeat;
  double _resolution;
  late final _raster = PaintedRaster(onReady: _ready);

  /// Counts the paintings asked, so that a new one rasterizes again.
  int _painting = 0;

  RenderRasterPaint(this._painter, this._repeat, this._resolution);

  /// The bitmap kept, once painted.
  @visibleForTesting
  ui.Image? get image => _raster.image;

  set painter(CustomPainter value) {
    final old = _painter;
    _painter = value;
    if (old.runtimeType != value.runtimeType || value.shouldRepaint(old)) {
      _painting++;
      markNeedsPaint();
    }
  }

  set repeat(int value) {
    if (value == _repeat) return;
    _repeat = value;
    markNeedsPaint();
  }

  FilterQuality _filterQuality = FilterQuality.low;

  set filterQuality(FilterQuality value) {
    if (value == _filterQuality) return;
    _filterQuality = value;
    markNeedsPaint();
  }

  set resolution(double value) {
    if (value == _resolution) return;
    _resolution = value;
    markNeedsPaint();
  }

  void _ready() {
    if (attached) markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void paint(PaintingContext context, Offset offset) {
    final tile = Size(size.width / _repeat, size.height);
    _raster.prepare(_painting, Offset.zero & tile, _resolution,
        (canvas) => _painter.paint(canvas, tile));
    for (var i = 0; i < _repeat; i++) {
      _raster.drawOn(context.canvas,
          offset: offset.translate(i * tile.width, 0),
          filterQuality: _filterQuality);
    }
  }

  @override
  void dispose() {
    _raster.dispose();
    super.dispose();
  }
}

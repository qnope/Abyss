import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'kept_rasters.dart';
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
/// ready. Given [keepAs], its latest bitmap outlives it (see
/// [KeptRasters]): shown again unchanged, it is not rasterized again.
/// Fills its box.
class RasterPaint extends LeafRenderObjectWidget {
  final CustomPainter painter;
  final int repeat;
  final double? resolution;
  final FilterQuality filterQuality;

  /// The name its bitmap is kept as when it is gone, if any.
  final Object? keepAs;

  const RasterPaint({
    super.key,
    required this.painter,
    this.repeat = 1,
    this.resolution,
    this.filterQuality = FilterQuality.low,
    this.keepAs,
  });

  double _resolutionIn(BuildContext context) =>
      resolution ?? MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;

  @override
  RenderRasterPaint createRenderObject(BuildContext context) =>
      RenderRasterPaint(painter, repeat, _resolutionIn(context),
          keepAs: keepAs)
        ..filterQuality = filterQuality;

  @override
  void updateRenderObject(
      BuildContext context, RenderRasterPaint renderObject) {
    renderObject
      ..painter = painter
      ..repeat = repeat
      ..resolution = _resolutionIn(context)
      ..filterQuality = filterQuality
      ..keepAs = keepAs;
  }
}

/// The render object of a [RasterPaint], keeping its bitmap.
class RenderRasterPaint extends RenderBox {
  CustomPainter _painter;
  int _repeat;
  double _resolution;
  late final PaintedRaster _raster;

  /// Counts the paintings asked, so that a new one rasterizes again.
  int _painting = 0;

  /// The name its bitmap is kept as when it is disposed, if any.
  Object? keepAs;

  /// Takes back the bitmap kept as [keepAs], if any.
  RenderRasterPaint(this._painter, this._repeat, this._resolution,
      {this.keepAs}) {
    final name = keepAs;
    final kept = name == null ? null : KeptRasters.take(name);
    _raster = (kept?.raster ?? PaintedRaster())..onReady = _ready;
    if (kept != null) {
      _painting = kept.painting + (_differs(kept.painter) ? 1 : 0);
    }
  }

  bool _differs(CustomPainter old) =>
      old.runtimeType != _painter.runtimeType || _painter.shouldRepaint(old);

  /// The bitmap kept, once painted.
  @visibleForTesting
  ui.Image? get image => _raster.image;

  set painter(CustomPainter value) {
    final old = _painter;
    _painter = value;
    if (_differs(old)) {
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
    final name = keepAs;
    name == null
        ? _raster.dispose()
        : KeptRasters.keep(name, KeptRaster(_raster, _painter, _painting));
    super.dispose();
  }
}

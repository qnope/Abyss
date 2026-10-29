import 'dart:ui';

import 'map_content_fade.dart';
import 'map_content_spot.dart';

/// Draws the contents of a standing layer as [fade] says, spot by spot:
/// a content faded out is skipped, one fading in is drawn apart, in a
/// layer at the fade's opacity, and every other one as it is.
///
/// Which spots fade is worked out once per set of cells faded, and the
/// layer's paint is reused, so a frame allocates next to nothing.
class MapStandingFade {
  final MapContentFade? fade;
  final List<MapContentSpot> _spots;
  final int _columns;

  /// Whether the content of each spot stands on a cell of [_cells].
  final List<bool> _faded;
  Set<(int, int)>? _cells;
  final _layer = Paint();
  double _layerOpacity = -1;

  MapStandingFade(this.fade, this._spots, this._columns)
      : _faded = List.filled(_spots.length, false);

  /// How much the content of the [k]-th spot shows: 0 hidden, 1 whole.
  double opacityOf(int k) {
    final fade = this.fade;
    if (fade == null || fade.opacity >= 1) return 1;
    if (!identical(fade.cells, _cells)) _mark(fade.cells);
    return _faded[k] ? fade.opacity : 1;
  }

  /// Starts drawing the content of the [k]-th spot, apart when it fades
  /// in; `false` when it is faded out and must not be drawn.
  bool begin(Canvas canvas, int k) {
    final opacity = opacityOf(k);
    if (opacity <= 0) return false;
    if (opacity >= 1) return true;
    if (opacity != _layerOpacity) {
      _layer.color = Color.fromRGBO(0, 0, 0, opacity);
      _layerOpacity = opacity;
    }
    canvas.saveLayer(_spots[k].bounds, _layer);
    return true;
  }

  /// Ends drawing the content of the [k]-th spot, begun by [begin].
  void end(Canvas canvas, int k) {
    if (opacityOf(k) < 1) canvas.restore();
  }

  void _mark(Set<(int, int)> cells) {
    _cells = cells;
    for (var k = 0; k < _spots.length; k++) {
      final index = _spots[k].index;
      _faded[k] = cells.contains((index % _columns, index ~/ _columns));
    }
  }
}

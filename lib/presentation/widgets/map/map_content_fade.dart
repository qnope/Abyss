import 'package:flutter/foundation.dart';

/// The contents the standing layer fades while an effect plays over their
/// cells: the content standing on each of [cells] shows at [opacity],
/// every other one whole.
///
/// Ready once constructed, showing every content whole. It is told of
/// each moment of the effect and notifies only when it changes, so an
/// effect fading nothing never repaints the map.
class MapContentFade extends ChangeNotifier {
  Set<(int, int)> _cells = const {};
  double _opacity = 1;

  /// The cells whose content fades.
  Set<(int, int)> get cells => _cells;

  /// How much the contents of [cells] show: 0 hidden, 1 whole.
  double get opacity => _opacity;

  /// Shows the contents of [cells] at [opacity].
  void fade(Set<(int, int)> cells, double opacity) {
    if (identical(cells, _cells) && opacity == _opacity) return;
    _cells = cells;
    _opacity = opacity;
    notifyListeners();
  }

  /// Shows every content whole again.
  void clear() => fade(const {}, 1);
}

import 'package:flutter/widgets.dart';

import 'effects/map_effect.dart';
import 'effects/map_effects.dart';
import 'map_projection.dart';
import 'map_viewport.dart';

/// Moves a map through its [controller], keeping the cell that matters in
/// the middle: its [home] when the map first shows, then the focus of
/// each effect [effects] plays.
///
/// The state calls [centre] whenever its dependencies or its widget
/// change: a story opening the map for its effect plays it at once, so
/// the map is already on it when it first shows.
mixin MapCentring<T extends StatefulWidget> on State<T> {
  /// Tiles seen across the screen when the map first shows.
  static const homeVisibleTiles = 4.5;

  MapEffect? _focused;

  /// The transform of the map, disposed with the state.
  final controller = TransformationController();

  /// The cell shown first.
  (int, int) get home;

  /// Rows of the map, which place its cells in the map's box.
  int get rows;

  /// The effects played over the map, if any.
  MapEffects? get effects;

  /// Centres on [home] before the first frame, so the map never shows a
  /// jump, then on the focus of a new effect, keeping the zoom.
  void centre() {
    final screen = MediaQuery.sizeOf(context);
    if (controller.value.isIdentity()) {
      controller.value = MapViewport.centeredOn(screen, home,
          rows: rows, visibleTiles: homeVisibleTiles);
    }
    final effect = effects?.current, focus = effect?.focus;
    if (focus == null || effect == _focused) return;
    _focused = effect;
    final scale = controller.value.getMaxScaleOnAxis();
    controller.value = MapViewport.centeredOn(screen, focus,
        rows: rows,
        visibleTiles: screen.width / (scale * MapProjection.tileWidth));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

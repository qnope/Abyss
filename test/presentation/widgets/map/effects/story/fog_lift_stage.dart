import 'dart:ui' as ui;

import 'package:abyss/presentation/widgets/map/effects/map_effect.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';

/// A stage where every bitmap, pools and shadow included, is [bitmap].
class FogLiftStage extends MapStage {
  final ui.Image bitmap;

  FogLiftStage(this.bitmap) : super(originOf: (cell) => cell);

  @override
  ui.Image? image(String path) => bitmap;

  @override
  ui.Image? pool(MapGlow glow) => bitmap;

  @override
  ui.Image? get shadow => bitmap;
}

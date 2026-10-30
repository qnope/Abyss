import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../domain/building/building_type.dart';
import '../map/map_sprites.dart';
import 'base_buildings_layer.dart';
import 'base_fit.dart';
import 'base_guide_halo.dart';
import 'base_island_painter.dart';
import 'base_layout.dart';
import 'base_rampart.dart';
import 'base_rampart_painter.dart';
import 'base_snapshot.dart';
import 'base_sprites.dart';

/// The base of [layout] seen through [fit], from the back to the front,
/// each layer within its own repaint boundary: the still island (cached),
/// the guide's ring on its ground, the buildings alive on the ambience
/// [clock], then the front of the coral rampart once the citadel stands.
///
/// Only the buildings repaint as the base lives.
class BaseLayers extends StatelessWidget {
  final BaseLayout layout;
  final BaseFit fit;
  final BaseSnapshot snapshot;
  final BaseSprites? sprites;
  final ValueListenable<double>? clock;

  const BaseLayers({
    super.key,
    required this.layout,
    required this.fit,
    required this.snapshot,
    this.sprites,
    this.clock,
  });

  @override
  Widget build(BuildContext context) {
    final rampart = BaseRampart.of(
        layout, snapshot.levels[BuildingType.coralCitadel] ?? 0);
    return Stack(fit: StackFit.expand, children: [
      RepaintBoundary(
        child: CustomPaint(
          painter: BaseIslandPainter(
            layout: layout,
            tiers: snapshot.tiers,
            fit: fit,
            sprites: sprites?.map ?? MapSprites.ready,
            rampart: rampart,
          ),
        ),
      ),
      BaseGuideHalo(layout: layout, fit: fit),
      BaseBuildingsLayer(
        layout: layout,
        fit: fit,
        snapshot: snapshot,
        sprites: sprites,
        clock: clock,
      ),
      if (rampart.level > 0)
        RepaintBoundary(
          child: CustomPaint(
            painter: BaseRampartPainter(rampart: rampart, fit: fit),
          ),
        ),
    ]);
  }
}

import 'package:flutter/material.dart';

import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/worksite/worksite.dart';
import '../ambience/ambience_clock_scope.dart';
import '../map/map_snow_layer.dart';
import '../map/map_sprites.dart';
import 'base_badges_layer.dart';
import 'base_building_semantics.dart';
import 'base_buildings_painter.dart';
import 'base_fit.dart';
import 'base_guide_halo.dart';
import 'base_hit.dart';
import 'base_hud.dart';
import 'base_island_painter.dart';
import 'base_layout.dart';
import 'base_snapshot.dart';
import 'base_sprites.dart';

/// The player's base seen as an island in the abyss, fitted to the view
/// with no pan nor zoom: the still island with the pads (cached in its
/// own layer), the guide's ring on the ground, the eleven [buildings]
/// standing on the pads, the degraded ones greyed, their marks (level,
/// « À bâtir » with a lock on the [locked] plots, a chevron over the
/// [upgradable] ones, a triangle over the degraded ones), a light marine
/// snow and the worksite and rampart banners at the top.
///
/// Touching a building (the one in front where two overlap, else the
/// footprint under the finger) calls [onBuildingTap], built or not; a
/// screen reader finds and opens each one by its name. The ambience
/// clock of the base is shared by everything that moves on it.
class BaseView extends StatefulWidget {
  final Map<BuildingType, Building> buildings;
  final Worksite worksite;
  final void Function(Building building) onBuildingTap;
  final BaseLayout layout;

  /// The buildings that can go up a level right now.
  final Set<BuildingType> upgradable;

  /// The buildings a missing prerequisite keeps from rising.
  final Set<BuildingType> locked;

  const BaseView({
    super.key,
    required this.buildings,
    required this.worksite,
    required this.onBuildingTap,
    this.layout = BaseLayout.island,
    this.upgradable = const {},
    this.locked = const {},
  });

  @override
  State<BaseView> createState() => _BaseViewState();
}

class _BaseViewState extends State<BaseView> {
  BaseSprites? _sprites = BaseSprites.ready;

  @override
  void initState() {
    super.initState();
    if (_sprites != null) return;
    BaseSprites.load().then(
      (sprites) {
        if (mounted) setState(() => _sprites = sprites);
      },
      onError: (Object error) => debugPrint('Base sprites failed: $error'),
    );
  }

  @override
  Widget build(BuildContext context) => AmbienceClockScope(
        builder: (context, clock) => LayoutBuilder(
          builder: (context, constraints) {
            final fit = BaseFit.of(constraints.biggest, widget.layout);
            final base = BaseSnapshot.of(widget.buildings,
                upgradable: widget.upgradable, locked: widget.locked);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTapUp: (details) => _tap(details.localPosition, fit, base),
              child: Stack(fit: StackFit.expand, children: [
                ..._layers(fit, base),
                BaseBadgesLayer(
                    layout: widget.layout, fit: fit, snapshot: base),
                MapSnowLayer(clock: clock),
                BaseBuildingSemantics(
                  layout: widget.layout,
                  fit: fit,
                  buildings: widget.buildings,
                  snapshot: base,
                  onBuildingTap: widget.onBuildingTap,
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: BaseHud(
                    worksite: widget.worksite,
                    buildings: widget.buildings,
                  ),
                ),
              ]),
            );
          },
        ),
      );

  /// The still island, the guide's ring on its ground, then the
  /// buildings, each within its own boundary.
  List<Widget> _layers(BaseFit fit, BaseSnapshot base) => [
      RepaintBoundary(
        child: CustomPaint(
          painter: BaseIslandPainter(
            layout: widget.layout,
            tiers: base.tiers,
            fit: fit,
            sprites: _sprites?.map ?? MapSprites.ready,
          ),
        ),
      ),
      BaseGuideHalo(layout: widget.layout, fit: fit),
      RepaintBoundary(
        child: CustomPaint(
          painter: BaseBuildingsPainter(
            layout: widget.layout,
            levels: base.levels,
            degraded: base.degraded,
            fit: fit,
            sprites: _sprites,
          ),
        ),
      ),
    ];

  void _tap(Offset position, BaseFit fit, BaseSnapshot base) {
    final type = baseBuildingAt(fit.toProjection(position), widget.layout,
        tiers: base.tiers);
    final building = type == null ? null : widget.buildings[type];
    if (building != null) widget.onBuildingTap(building);
  }
}

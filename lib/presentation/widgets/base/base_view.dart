import 'package:flutter/material.dart';

import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/worksite/worksite.dart';
import '../ambience/ambience_clock_scope.dart';
import '../building/worksite_badge.dart';
import '../map/map_snow_layer.dart';
import '../map/map_sprites.dart';
import 'base_buildings_painter.dart';
import 'base_fit.dart';
import 'base_guide_halo.dart';
import 'base_hit.dart';
import 'base_island_painter.dart';
import 'base_layout.dart';
import 'base_sprites.dart';

/// The player's base seen as an island in the abyss, fitted to the view
/// with no pan nor zoom: the still island (cached in its own layer), the
/// eleven [buildings] standing on it, a light marine snow, the guide's
/// halo and the worksite badge at the top.
///
/// Touching a building (the one in front where two overlap, else the
/// footprint under the finger) calls [onBuildingTap], built or not. The
/// ambience clock of the base is shared by everything that moves on it.
class BaseView extends StatefulWidget {
  final Map<BuildingType, Building> buildings;
  final Worksite worksite;
  final void Function(Building building) onBuildingTap;
  final BaseLayout layout;

  const BaseView({
    super.key,
    required this.buildings,
    required this.worksite,
    required this.onBuildingTap,
    this.layout = BaseLayout.island,
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
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) => _tap(details.localPosition, fit),
              child: Stack(fit: StackFit.expand, children: [
                ..._layers(fit),
                MapSnowLayer(clock: clock),
                BaseGuideHalo(layout: widget.layout, fit: fit),
                Positioned(
                  left: 0,
                  top: 0,
                  child: WorksiteBadge(
                    worksite: widget.worksite,
                    buildings: widget.buildings,
                  ),
                ),
              ]),
            );
          },
        ),
      );

  /// The still island, then the buildings, each within its own boundary.
  List<Widget> _layers(BaseFit fit) {
    final levels = {
      for (final MapEntry(:key, :value) in widget.buildings.entries)
        key: value.level,
    };
    return [
      RepaintBoundary(
        child: CustomPaint(
          painter: BaseIslandPainter(
            layout: widget.layout,
            built: {
              for (final MapEntry(:key, :value) in levels.entries)
                if (value > 0) key,
            },
            fit: fit,
            sprites: _sprites?.map ?? MapSprites.ready,
          ),
        ),
      ),
      RepaintBoundary(
        child: CustomPaint(
          painter: BaseBuildingsPainter(
            layout: widget.layout,
            levels: levels,
            fit: fit,
            sprites: _sprites,
          ),
        ),
      ),
    ];
  }

  void _tap(Offset position, BaseFit fit) {
    final type = baseBuildingAt(fit.toProjection(position), widget.layout);
    final building = type == null ? null : widget.buildings[type];
    if (building != null) widget.onBuildingTap(building);
  }
}

import 'package:flutter/material.dart';

import '../../../domain/building/building.dart';
import '../../../domain/building/building_degradation.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/unit/unit_cost_calculator.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/building_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../base/base_fit.dart';
import '../base/base_sprites.dart';
import '../building/base_shield_badge.dart';
import '../common/raster_paint.dart';
import 'army_fit.dart';
import 'army_island_painter.dart';

/// The army seen as a parade ground in the abyss, an island like the
/// base's fitted to the view with no pan nor zoom: the still island (see
/// [ArmyIslandPainter]) rasterized into a single bitmap kept when the
/// army is left, and the rampart's badge at the top once the Coral
/// Citadel stands.
///
/// Touching a drill pad calls [onUnitTap] with its unit, locked or not;
/// touching elsewhere does nothing.
class ArmyView extends StatefulWidget {
  /// The name the island's bitmap is kept as when the army is left.
  static const islandName = 'army island';

  final Map<BuildingType, Building> buildings;
  final void Function(UnitType type) onUnitTap;

  /// Whether a missing prerequisite keeps the barracks from being built.
  final bool barracksLocked;

  const ArmyView({
    super.key,
    required this.buildings,
    required this.onUnitTap,
    this.barracksLocked = false,
  });

  @override
  State<ArmyView> createState() => _ArmyViewState();
}

class _ArmyViewState extends State<ArmyView> {
  static final _units = UnitCostCalculator();

  BaseSprites? _sprites = BaseSprites.ready;

  @override
  void initState() {
    super.initState();
    if (_sprites != null) return;
    BaseSprites.load().then(
      (sprites) {
        if (mounted) setState(() => _sprites = sprites);
      },
      onError: (Object error) => debugPrint('Army sprites failed: $error'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const barracks = BuildingType.barracks;
    final level = widget.buildings[barracks]?.level ?? 0;
    return LayoutBuilder(builder: (context, constraints) {
      final fit = ArmyFit.of(constraints.biggest);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) => _tap(details.localPosition, fit),
        child: Stack(fit: StackFit.expand, children: [
          RepaintBoundary(
            child: RasterPaint(
              keepAs: ArmyView.islandName,
              painter: ArmyIslandPainter(
                fit: fit,
                barracksLevel: level,
                barracksDegraded:
                    BuildingDegradation.isDegraded(widget.buildings, barracks),
                barracksLocked: widget.barracksLocked,
                unlocked: {
                  for (final type in UnitType.values)
                    if (_units.isUnlocked(type, level)) type,
                },
                toBuild: l10n.baseToBuild,
                barracksName: barracks.displayName(l10n),
                sprites: _sprites,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: BaseShieldBadge(buildings: widget.buildings),
          ),
        ]),
      );
    });
  }

  void _tap(Offset position, BaseFit fit) {
    final type = armyUnitAt(position, fit);
    if (type != null) widget.onUnitTap(type);
  }
}

import 'package:flutter/material.dart';

import '../../../domain/building/building.dart';
import '../../../domain/building/building_degradation.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/unit/unit_type.dart';
import '../base/base_fit.dart';
import '../base/base_sprites.dart';
import '../building/base_shield_badge.dart';
import 'army_fit.dart';
import 'army_hit.dart';
import 'army_layers.dart';
import 'army_piece.dart';
import 'army_roster.dart';
import 'army_semantics.dart';
import 'army_sprites.dart';

/// The army seen as a parade ground in the abyss, an island like the
/// base's fitted to the view with no pan nor zoom (see [ArmyLayers]): the
/// still island kept as a bitmap, the squads of [counts] units standing
/// on it with their banners, and their plaques, a green « + » on the
/// [recruitable] ones; the rampart's badge at the top once the Coral
/// Citadel stands.
///
/// Touching a squad (one of its figures, its banner or its pad; the one
/// in front where two overlap) calls [onUnitTap] with its unit, locked or
/// not; touching the barracks calls [onBarracksTap]. A screen reader
/// finds and opens each squad and the barracks by its name.
class ArmyView extends StatefulWidget {
  /// The name the island's bitmap is kept as when the army is left.
  static const islandName = ArmyLayers.islandName;

  final Map<BuildingType, Building> buildings;
  final void Function(UnitType type) onUnitTap;
  final void Function(Building barracks)? onBarracksTap;

  /// Units of each type standing on the ground: wherever they serve, or
  /// at the place shown (see ArmyPlacesView).
  final Map<UnitType, int> counts;

  /// The types the player can recruit at least one of this turn.
  final Set<UnitType> recruitable;

  /// Whether a missing prerequisite keeps the barracks from being built.
  final bool barracksLocked;

  /// Height kept free at the bottom for what floats there, the parade
  /// ground fitted above it (see [ArmyFit]).
  final double bottomSpace;

  const ArmyView({
    super.key,
    required this.buildings,
    required this.onUnitTap,
    this.onBarracksTap,
    this.counts = const {},
    this.recruitable = const {},
    this.barracksLocked = false,
    this.bottomSpace = 0,
  });

  @override
  State<ArmyView> createState() => _ArmyViewState();
}

class _ArmyViewState extends State<ArmyView> {
  BaseSprites? _base = BaseSprites.ready;
  ArmySprites? _army = ArmySprites.ready;

  @override
  void initState() {
    super.initState();
    if (_base == null) _load(BaseSprites.load, (sprites) => _base = sprites);
    if (_army == null) _load(ArmySprites.load, (sprites) => _army = sprites);
  }

  void _load<T>(Future<T> Function() load, void Function(T sprites) keep) =>
      load().then((sprites) {
        if (mounted) setState(() => keep(sprites));
      }, onError: (Object error) => debugPrint('Army sprites failed: $error'));

  @override
  Widget build(BuildContext context) {
    const type = BuildingType.barracks;
    final barracks = widget.buildings[type];
    final degraded = BuildingDegradation.isDegraded(widget.buildings, type);
    final roster = ArmyRoster(
      barracksLevel: barracks?.level ?? 0,
      counts: widget.counts,
      recruitable: widget.recruitable,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final bottom = widget.bottomSpace;
        final fit = ArmyFit.of(constraints.biggest, bottom: bottom);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTapUp: (details) => _tap(details.localPosition, fit, roster),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ArmyLayers(
                fit: fit,
                roster: roster,
                barracksDegraded: degraded,
                barracksLocked: widget.barracksLocked,
                base: _base,
                army: _army,
              ),
              ArmySemantics(
                fit: fit,
                roster: roster,
                barracks: barracks,
                barracksDegraded: degraded,
                onUnitTap: widget.onUnitTap,
                onBarracksTap: widget.onBarracksTap,
              ),
              Positioned(
                left: 0,
                top: 0,
                child: BaseShieldBadge(buildings: widget.buildings),
              ),
            ],
          ),
        );
      },
    );
  }

  void _tap(Offset position, BaseFit fit, ArmyRoster roster) {
    switch (armyPieceAt(fit.toProjection(position), roster)) {
      case UnitPiece(:final type):
        widget.onUnitTap(type);
      case BarracksPiece():
        final barracks = widget.buildings[BuildingType.barracks];
        if (barracks != null) widget.onBarracksTap?.call(barracks);
      case DepotPiece() || null:
        break;
    }
  }
}

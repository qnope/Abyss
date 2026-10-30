import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../../domain/building/building_type.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/building_type_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../base/base_fit.dart';
import '../common/back_to_front.dart' as order;
import 'army_barracks_drawer.dart';
import 'army_layout.dart';
import 'army_plaque.dart';
import 'army_plaque_arrival_drawer.dart';
import 'army_plaque_drawer.dart';
import 'army_roster.dart';
import 'army_squad_geometry.dart';
import 'squad_arrival.dart';

/// Paints the marks floating over the parade ground, above the squads:
/// the barracks' plaque (its level, or the « À bâtir » pill of its plot,
/// locked while [barracksLocked]) and the plaque of every squad, back to
/// front, each kept inside the view (see [ArmyPlaqueDrawer.placed]); the
/// plaques of the squads a recruit is [arriving] on count it as the
/// [arrival] runs (see [ArmyPlaqueArrivalDrawer]).
///
/// Cheap and apart from the squads: repainted only when a count, a
/// badge, the barracks or the language changes, and while recruits
/// arrive.
class ArmyMarksPainter extends CustomPainter {
  static const _plaques = ArmyPlaqueDrawer();

  /// The squads from the back to the front, so that a nearer plaque
  /// covers a farther one.
  static final _order = order.backToFront(
    UnitType.values,
    (type) => ArmyLayout.depthOf(ArmyLayout.padCentre(type)),
  );

  final BaseFit fit;
  final ArmyRoster roster;
  final AppLocalizations l10n;

  /// Whether a missing prerequisite keeps the barracks from being built.
  final bool barracksLocked;

  /// The progress of the recruits [arriving], from 0 to 1.
  final Animation<double>? arrival;
  final Map<UnitType, SquadArrival> arriving;

  ArmyMarksPainter({
    required this.fit,
    required this.roster,
    required this.l10n,
    this.barracksLocked = false,
    this.arrival,
    this.arriving = const {},
  }) : super(repaint: arrival);

  @override
  void paint(Canvas canvas, Size size) {
    final left = fit.toProjection(Offset.zero).dx;
    final right = fit.toProjection(Offset(size.width, 0)).dx;
    final t = arrival?.value ?? 1;
    canvas.save();
    fit.apply(canvas);
    ArmyBarracksDrawer().paintPlaque(
      canvas,
      level: roster.barracksLevel,
      name: BuildingType.barracks.displayName(l10n),
      toBuild: l10n.baseToBuild,
      locked: barracksLocked,
    );
    for (final type in _order) {
      final plaque = ArmyPlaque.of(type, roster, l10n);
      final at = _plaques.placed(
        ArmySquadGeometry.plaqueAt(type),
        plaque,
        left: left,
        right: right,
      );
      final coming = t < 1 ? arriving[type] : null;
      if (coming == null) {
        _plaques.paint(canvas, at, plaque);
        continue;
      }
      final before = roster.withCount(
        type,
        roster.countOf(type) - coming.gained,
      );
      const ArmyPlaqueArrivalDrawer(_plaques).paint(
        canvas,
        at,
        before: ArmyPlaque.of(type, before, l10n),
        after: plaque,
        arrival: coming,
        t: t,
        zoom: fit.zoom,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(ArmyMarksPainter oldDelegate) =>
      oldDelegate.fit != fit ||
      oldDelegate.roster != roster ||
      oldDelegate.barracksLocked != barracksLocked ||
      oldDelegate.arrival != arrival ||
      !mapEquals(oldDelegate.arriving, arriving) ||
      oldDelegate.l10n.localeName != l10n.localeName;

  @override
  bool? hitTest(Offset position) => false;
}

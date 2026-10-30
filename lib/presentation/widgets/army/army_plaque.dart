import 'dart:ui';

import '../../../domain/unit/unit_type.dart';
import '../../extensions/unit_army_texts.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/abyss_army_colors.dart';
import 'army_roster.dart';

/// What the plaque at the front of a squad's pad says: how many units
/// serve, in the squad's [colour], with its [name] below and the green
/// « + » when it can recruit now; or, while the barracks is too low, the
/// level it waits for in a dashed pill with a lock.
class ArmyPlaque {
  /// The count, « 22 »; none while locked.
  final String? count;

  /// The barracks level the unit waits for, « Caserne niv. 3 »; none
  /// once unlocked.
  final String? lock;

  /// The squad's name under its count or lock.
  final String name;

  final Color colour;

  /// Whether the green « + » stands right of the count.
  final bool recruitable;

  const ArmyPlaque({
    required this.name,
    required this.colour,
    this.count,
    this.lock,
    this.recruitable = false,
  });

  /// The plaque of the squad of [type] in [roster], in the language of
  /// [l10n].
  factory ArmyPlaque.of(
    UnitType type,
    ArmyRoster roster,
    AppLocalizations l10n,
  ) {
    final count = roster.countOf(type);
    final locked = roster.isLocked(type);
    return ArmyPlaque(
      name: type.plaqueName(l10n, count, locked: locked),
      colour: AbyssArmyColors.of(type),
      count: locked ? null : '$count',
      lock: locked ? l10n.armyLockPill(roster.unlockLevelOf(type)) : null,
      recruitable: roster.canRecruit(type),
    );
  }

  /// Whether the squad has no unit yet: its count is drawn dimmed.
  bool get isEmpty => count == '0';
}

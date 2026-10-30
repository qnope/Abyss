import 'package:flutter/foundation.dart';

import '../../../domain/unit/unit_cost_calculator.dart';
import '../../../domain/unit/unit_type.dart';
import 'squad_size.dart';

/// The army as the parade ground shows it: the barracks' level, which
/// unlocks the units, how many units of each type serve, and the types
/// that can recruit right now.
@immutable
class ArmyRoster {
  static final _units = UnitCostCalculator();

  final int barracksLevel;

  /// Units of each type, wherever they serve; a missing type has none.
  final Map<UnitType, int> counts;

  /// The types the player can recruit at least one of this turn.
  final Set<UnitType> recruitable;

  const ArmyRoster({
    required this.barracksLevel,
    this.counts = const {},
    this.recruitable = const {},
  });

  /// Units of [type] serving.
  int countOf(UnitType type) => counts[type] ?? 0;

  /// The barracks level that unlocks [type].
  int unlockLevelOf(UnitType type) => _units.unlockLevel(type);

  /// Whether the barracks is still too low for [type].
  bool isLocked(UnitType type) => !_units.isUnlocked(type, barracksLevel);

  /// The types the barracks lets recruit.
  Set<UnitType> get unlocked => {
    for (final type in UnitType.values)
      if (!isLocked(type)) type,
  };

  /// Figures standing for [type]: one ghost while it is locked, else as
  /// many as its count's tier (see [SquadSize]).
  int figuresOf(UnitType type) =>
      isLocked(type) ? 1 : SquadSize.of(countOf(type));

  /// Whether [type] shows the green « + »: unlocked and recruitable now.
  bool canRecruit(UnitType type) =>
      !isLocked(type) && recruitable.contains(type);

  @override
  bool operator ==(Object other) =>
      other is ArmyRoster &&
      other.barracksLevel == barracksLevel &&
      mapEquals(other.counts, counts) &&
      setEquals(other.recruitable, recruitable);

  @override
  int get hashCode => Object.hash(
    barracksLevel,
    Object.hashAllUnordered(counts.entries.map((e) => (e.key, e.value))),
    Object.hashAllUnordered(recruitable),
  );
}

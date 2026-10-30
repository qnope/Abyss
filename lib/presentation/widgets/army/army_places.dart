import 'package:flutter/foundation.dart';

import '../../../domain/unit/unit_type.dart';

/// Where the army serves: the units of each type at each place, a level
/// of the map (1 to 3) or the kernel's stock (`KernelGarrison.stockKey`),
/// as the player keeps them. A place is named by its key, the whole army
/// by [all].
@immutable
class ArmyPlaces {
  /// The whole army, every place together.
  static const int? all = null;

  /// Units of each type at each place; a missing type has none there.
  final Map<int, Map<UnitType, int>> units;

  const ArmyPlaces([this.units = const {}]);

  /// The places holding at least one unit, in the order of their keys:
  /// the levels from the top down, then the kernel.
  List<int> get held => [
    for (final place in units.keys.toList()..sort())
      if (totalAt(place) > 0) place,
  ];

  /// Whether the army serves in more than one place.
  bool get isSplit => held.length > 1;

  /// Units of each type at [place], every place for [all]; the types
  /// with none left out.
  Map<UnitType, int> countsAt(int? place) {
    final counts = <UnitType, int>{};
    for (final MapEntry(key: at, value: types) in units.entries) {
      if (place != all && at != place) continue;
      for (final MapEntry(key: type, value: count) in types.entries) {
        if (count > 0) counts[type] = (counts[type] ?? 0) + count;
      }
    }
    return counts;
  }

  /// Units of [type] at [place], every place for [all].
  int countOf(UnitType type, int? place) => countsAt(place)[type] ?? 0;

  /// Units of every type at [place], every place for [all].
  int totalAt(int? place) =>
      countsAt(place).values.fold(0, (total, count) => total + count);

  /// The counts of each place holding units, the empty ones left out.
  Map<int, Map<UnitType, int>> get _held => {
    for (final place in held) place: countsAt(place),
  };

  @override
  bool operator ==(Object other) {
    if (other is! ArmyPlaces) return false;
    final mine = _held, theirs = other._held;
    return setEquals(mine.keys.toSet(), theirs.keys.toSet()) &&
        mine.keys.every((place) => mapEquals(mine[place], theirs[place]));
  }

  @override
  int get hashCode => Object.hashAllUnordered([
    for (final MapEntry(key: place, value: counts) in _held.entries)
      Object.hash(
        place,
        Object.hashAllUnordered(counts.entries.map((e) => (e.key, e.value))),
      ),
  ]);
}

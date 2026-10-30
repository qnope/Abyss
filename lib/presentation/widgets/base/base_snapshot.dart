import '../../../domain/building/building.dart';
import '../../../domain/building/building_degradation.dart';
import '../../../domain/building/building_type.dart';
import 'base_badge.dart';
import 'base_pad_tier.dart';

/// What the base view reads from the buildings: their [levels], the
/// [tiers] of their pads, the ones [degraded] by a headquarters too low
/// for them, the built ones [upgradable] now and the plots [locked] by a
/// missing prerequisite.
///
/// The still island only depends on the [tiers], so raising a building
/// within its tier leaves it as it is.
class BaseSnapshot {
  /// The level of each building; 0 for one still to build.
  final Map<BuildingType, int> levels;

  /// The pad under each building.
  final Map<BuildingType, BasePadTier> tiers;

  /// The buildings greyed and still.
  final Set<BuildingType> degraded;

  /// The built buildings, not degraded, that can go up a level now.
  final Set<BuildingType> upgradable;

  /// The plots a missing prerequisite keeps from being built.
  final Set<BuildingType> locked;

  const BaseSnapshot({
    required this.levels,
    required this.tiers,
    required this.degraded,
    this.upgradable = const {},
    this.locked = const {},
  });

  /// The snapshot of [buildings], of which the [upgradable] ones can go
  /// up a level now and the [locked] ones lack a prerequisite.
  factory BaseSnapshot.of(
    Map<BuildingType, Building> buildings, {
    Set<BuildingType> upgradable = const {},
    Set<BuildingType> locked = const {},
  }) {
    final levels = {
      for (final MapEntry(:key, :value) in buildings.entries) key: value.level,
    };
    final degraded = {
      for (final type in buildings.keys)
        if (BuildingDegradation.isDegraded(buildings, type)) type,
    };
    bool built(BuildingType type) => (levels[type] ?? 0) > 0;
    return BaseSnapshot(
      levels: levels,
      tiers: levels.map(
        (type, level) => MapEntry(type, BasePadTier.ofLevel(level)),
      ),
      degraded: degraded,
      upgradable: {
        for (final type in upgradable)
          if (built(type) && !degraded.contains(type)) type,
      },
      locked: {
        for (final type in locked)
          if (levels.containsKey(type) && !built(type)) type,
      },
    );
  }

  /// The buildings built, at level 1 or more.
  Set<BuildingType> get built => {
    for (final MapEntry(:key, :value) in tiers.entries)
      if (value != BasePadTier.plot) key,
  };

  /// What floats over [type], if anything.
  BaseBadge? badgeOf(BuildingType type) => degraded.contains(type)
      ? BaseBadge.warning
      : upgradable.contains(type)
      ? BaseBadge.upgrade
      : null;
}

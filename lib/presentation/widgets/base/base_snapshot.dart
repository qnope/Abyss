import '../../../domain/building/building.dart';
import '../../../domain/building/building_degradation.dart';
import '../../../domain/building/building_type.dart';
import 'base_pad_tier.dart';

/// What the base view reads from the buildings: their [levels], the
/// [tiers] of their pads and the ones [degraded] by a headquarters too
/// low for them.
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

  const BaseSnapshot({
    required this.levels,
    required this.tiers,
    required this.degraded,
  });

  /// The snapshot of [buildings].
  factory BaseSnapshot.of(Map<BuildingType, Building> buildings) {
    final levels = {
      for (final MapEntry(:key, :value) in buildings.entries) key: value.level,
    };
    return BaseSnapshot(
      levels: levels,
      tiers: levels.map(
        (type, level) => MapEntry(type, BasePadTier.ofLevel(level)),
      ),
      degraded: {
        for (final type in buildings.keys)
          if (BuildingDegradation.isDegraded(buildings, type)) type,
      },
    );
  }

  /// The buildings built, at level 1 or more.
  Set<BuildingType> get built => {
    for (final MapEntry(:key, :value) in tiers.entries)
      if (value != BasePadTier.plot) key,
  };
}

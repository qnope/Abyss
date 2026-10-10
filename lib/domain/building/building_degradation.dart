import 'building.dart';
import 'building_cost_calculator.dart';
import 'building_type.dart';

/// A building keeps its level when the headquarters falls below the level
/// it asked for, but works badly until the headquarters is raised again.
///
/// Nothing is stored: the state is read from the headquarters level and
/// the prerequisites, so raising the headquarters restores everything.
abstract final class BuildingDegradation {
  static const BuildingCostCalculator _calculator = BuildingCostCalculator();

  /// Headquarters level [type] needs at its current level; `null` when it
  /// is unbuilt, is the headquarters, or needs none.
  static int? requiredHeadquarters(
    Map<BuildingType, Building> buildings,
    BuildingType type,
  ) {
    final int level = buildings[type]?.level ?? 0;
    if (level <= 0) return null;
    return _calculator.prerequisites(type, level)[BuildingType.headquarters];
  }

  /// Headquarters level [type] is missing, `null` when it is not degraded.
  /// A QG at 0 (a bare fixture; a real one never goes below 1) degrades
  /// nothing.
  static int? missingHeadquarters(
    Map<BuildingType, Building> buildings,
    BuildingType type,
  ) {
    final int hq = buildings[BuildingType.headquarters]?.level ?? 0;
    final int? required = requiredHeadquarters(buildings, type);
    return hq > 0 && required != null && hq < required ? required : null;
  }

  static bool isDegraded(
    Map<BuildingType, Building> buildings,
    BuildingType type,
  ) => missingHeadquarters(buildings, type) != null;

  /// [amount] halved when [degraded], the rule of the production,
  /// the energy and the research.
  static int half(int amount, {required bool degraded}) =>
      degraded ? amount ~/ 2 : amount;
}

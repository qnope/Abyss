import 'building.dart';
import 'building_type.dart';

/// Defensive multiplier applied to player unit DEF when defending the base.
///
/// Level 0 (not built) → 1.0 (neutral, no effect).
/// Levels 1–5           → 1.2, 1.4, 1.6, 1.8, 2.0.
abstract final class CoralCitadelDefenseBonus {
  static double multiplierForLevel(int level) => switch (level) {
        <= 0 => 1.0,
        1 => 1.2,
        2 => 1.4,
        3 => 1.6,
        4 => 1.8,
        _ => 2.0,
      };

  /// Convenience: reads the Citadel level from a buildings map and returns
  /// the matching multiplier. Returns 1.0 when the building is absent.
  static double multiplierFromBuildings(
    Map<BuildingType, Building> buildings,
  ) {
    final level = buildings[BuildingType.coralCitadel]?.level ?? 0;
    return multiplierForLevel(level);
  }

  /// Human-readable bonus string, e.g. "+60%". Returns "aucun" for level 0.
  static String bonusLabel(int level) {
    if (level <= 0) return 'aucun';
    final percent = ((multiplierForLevel(level) - 1) * 100).round();
    return '+$percent%';
  }
}

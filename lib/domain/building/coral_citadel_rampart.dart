import '../fight/combat_role.dart';
import '../fight/combat_side.dart';
import '../fight/combatant.dart';
import 'building.dart';
import 'building_degradation.dart';
import 'building_type.dart';

/// The rampart the Coral Citadel raises when the base is raided.
///
/// It fights on the defenders' side and draws every monster attack while
/// it stands. With no ATK it only scratches (1 damage, like any ATK 0 unit). Each Citadel level adds [hpPerLevel] PV and
/// one point of DEF on top of [baseDef].
abstract final class CoralCitadelRampart {
  static const String typeKey = CombatRole.rampartKey;
  static const int hpPerLevel = 40;
  static const int baseDef = 4;

  static int hpForLevel(int level) => level <= 0 ? 0 : hpPerLevel * level;

  static int defForLevel(int level) => level <= 0 ? 0 : baseDef + level;

  static int levelOf(Map<BuildingType, Building> buildings) =>
      buildings[BuildingType.coralCitadel]?.level ?? 0;

  /// Rampart combatant for a Citadel at [level], or `null` when unbuilt.
  /// A [degraded] Citadel has half the PV and half the DEF.
  static Combatant? combatantFor(int level, {bool degraded = false}) {
    if (level <= 0) return null;
    return Combatant(
      side: CombatSide.player,
      typeKey: typeKey,
      maxHp: BuildingDegradation.half(hpForLevel(level), degraded: degraded),
      atk: 0,
      def: BuildingDegradation.half(defForLevel(level), degraded: degraded),
    );
  }

  /// The rampart of a base's [buildings], halved when the Citadel is
  /// degraded; `null` when unbuilt.
  static Combatant? combatantOf(Map<BuildingType, Building> buildings) =>
      combatantFor(
        levelOf(buildings),
        degraded: BuildingDegradation.isDegraded(
          buildings,
          BuildingType.coralCitadel,
        ),
      );
}

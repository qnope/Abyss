import '../unit/unit_type.dart';
import 'combat_side.dart';
import 'combatant.dart';

/// Special behaviour a player unit brings to a fight.
enum CombatRole {
  /// No special rule.
  none,

  /// Draws enemy attacks: monsters must target it while it stands.
  taunt,

  /// Deals double damage to bosses.
  bossBreaker,

  /// Ignores the target's DEF.
  armourPiercer,

  /// Flees instead of dying: always comes back wounded.
  evasive;

  /// Type key of the Coral Citadel rampart (see `CoralCitadelRampart`).
  static const String rampartKey = 'rampart';

  static CombatRole forUnit(UnitType type) => switch (type) {
        UnitType.guardian => CombatRole.taunt,
        UnitType.domeBreaker => CombatRole.bossBreaker,
        UnitType.saboteur => CombatRole.armourPiercer,
        UnitType.scout => CombatRole.evasive,
        UnitType.harpoonist || UnitType.abyssAdmiral => CombatRole.none,
      };

  /// Role of [combatant]; monsters never have one, the Citadel rampart
  /// always taunts.
  static CombatRole of(Combatant combatant) {
    if (combatant.side != CombatSide.player) return CombatRole.none;
    if (combatant.typeKey == rampartKey) return CombatRole.taunt;
    final UnitType? type = UnitType.values.asNameMap()[combatant.typeKey];
    return type == null ? CombatRole.none : forUnit(type);
  }
}

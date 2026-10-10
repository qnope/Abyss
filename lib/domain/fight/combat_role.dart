import '../unit/unit_type.dart';
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

  /// Unit types by name, built once: [of] runs on every attack.
  static final Map<String, UnitType> _unitTypes = UnitType.values.asNameMap();

  static CombatRole forUnit(UnitType type) => switch (type) {
        UnitType.guardian => CombatRole.taunt,
        UnitType.domeBreaker => CombatRole.bossBreaker,
        UnitType.saboteur => CombatRole.armourPiercer,
        UnitType.scout => CombatRole.evasive,
        UnitType.harpoonist || UnitType.abyssAdmiral => CombatRole.none,
      };

  /// Role of [combatant], read from its type key: no monster key is a
  /// unit's, so only units and the Citadel rampart have one, on either
  /// side (the defenders of a base fight on the side of the monsters).
  static CombatRole of(Combatant combatant) {
    if (combatant.typeKey == rampartKey) return CombatRole.taunt;
    final UnitType? type = _unitTypes[combatant.typeKey];
    return type == null ? CombatRole.none : forUnit(type);
  }
}

import '../fight/combat_side.dart';
import '../fight/combatant.dart';

/// The kernel fights beside its garrison: a wall of magma that grows with
/// the kernel's level. Unlike the Citadel rampart it does not draw the
/// attacks, but it strikes back.
abstract final class MagmaRampart {
  static const String typeKey = 'magmaRampart';
  static const int hpPerLevel = 40;
  static const int baseAtk = 4;
  static const int baseDef = 3;

  static int hpForLevel(int level) => level <= 0 ? 0 : hpPerLevel * level;

  static int atkForLevel(int level) => level <= 0 ? 0 : baseAtk + 2 * level;

  static int defForLevel(int level) => level <= 0 ? 0 : baseDef + level;

  /// Rampart combatant of a kernel at [level], or `null` at level 0.
  static Combatant? combatantFor(int level) {
    if (level <= 0) return null;
    return Combatant(
      side: CombatSide.player,
      typeKey: typeKey,
      maxHp: hpForLevel(level),
      atk: atkForLevel(level),
      def: defForLevel(level),
    );
  }
}

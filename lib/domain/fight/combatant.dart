import 'combat_side.dart';

class Combatant {
  final CombatSide side;
  final String typeKey;
  final int maxHp;
  int currentHp;
  final int atk;
  final int def;

  Combatant({
    required this.side,
    required this.typeKey,
    required this.maxHp,
    required this.atk,
    required this.def,
    int? currentHp,
  }) : currentHp = currentHp ?? maxHp;

  bool get isAlive => currentHp > 0;

  int applyDamage(int amount) {
    if (amount <= 0) {
      return 0;
    }
    final int before = currentHp;
    final int next = before - amount;
    currentHp = next < 0 ? 0 : next;
    return before - currentHp;
  }
}

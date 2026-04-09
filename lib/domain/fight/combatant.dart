import 'package:hive/hive.dart';
import 'combat_side.dart';

part 'combatant.g.dart';

@HiveType(typeId: 27)
class Combatant {
  @HiveField(0)
  final CombatSide side;

  @HiveField(1)
  final String typeKey;

  @HiveField(2)
  final int maxHp;

  @HiveField(3)
  final int atk;

  @HiveField(4)
  final int def;

  @HiveField(5)
  int currentHp;

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

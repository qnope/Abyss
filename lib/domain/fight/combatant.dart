import 'package:hive_ce/hive.dart';
import '../map/monster_family.dart';
import 'combat_role.dart';
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

  @HiveField(6, defaultValue: false)
  final bool isBoss;

  Combatant({
    required this.side,
    required this.typeKey,
    required this.maxHp,
    required this.atk,
    required this.def,
    int? currentHp,
    this.isBoss = false,
  }) : currentHp = currentHp ?? maxHp;

  /// Combat role, computed once since [side] and [typeKey] never change.
  late final CombatRole role = CombatRole.of(this);

  /// Monster family of [typeKey], computed once (`null` for player units).
  late final MonsterFamily? family = MonsterFamily.ofTypeKey(typeKey);

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

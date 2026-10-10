import '../fight/fight_result.dart';
import '../unit/unit_type.dart';
import 'action_result.dart';
import 'attack_base_defence.dart';
import 'base_damage.dart';

/// Outcome of an attack on another player's base. [victory] is the
/// attacker's; the army's casualties are its own, the defenders' are in
/// [defence].
class AttackBaseResult extends ActionResult {
  final bool victory;
  final FightResult? fight;
  final Map<UnitType, int> sent;
  final Map<UnitType, int> survivorsIntact;
  final Map<UnitType, int> wounded;
  final Map<UnitType, int> dead;
  final DefenceOutcome? _defence;
  final BaseDamage? _damage;

  AttackBaseResult.success({
    required this.victory,
    required FightResult this.fight,
    required this.sent,
    required this.survivorsIntact,
    required this.wounded,
    required this.dead,
    required DefenceOutcome defence,
    required BaseDamage damage,
  }) : _defence = defence,
       _damage = damage,
       super.success();

  const AttackBaseResult.failure(super.reason)
    : victory = false,
      fight = null,
      sent = const {},
      survivorsIntact = const {},
      wounded = const {},
      dead = const {},
      _defence = null,
      _damage = null,
      super.failure();

  /// The defenders and their fate; only for a successful attack.
  DefenceOutcome get defence => _defence!;

  /// What the attack did to the base; only for a successful attack.
  BaseDamage get damage => _damage!;
}

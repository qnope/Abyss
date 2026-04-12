import '../fight/fight_result.dart';
import '../unit/unit_type.dart';
import 'action_result.dart';

class AttackVolcanicKernelResult extends ActionResult {
  final bool victory;
  final bool captured;
  final FightResult? fight;
  final Map<UnitType, int> sent;
  final Map<UnitType, int> survivorsIntact;
  final Map<UnitType, int> wounded;
  final Map<UnitType, int> dead;

  AttackVolcanicKernelResult.success({
    required this.victory,
    required this.captured,
    required this.fight,
    required this.sent,
    required this.survivorsIntact,
    required this.wounded,
    required this.dead,
  }) : super.success();

  const AttackVolcanicKernelResult.failure(super.reason)
      : victory = false,
        captured = false,
        fight = null,
        sent = const {},
        survivorsIntact = const {},
        wounded = const {},
        dead = const {},
        super.failure();
}

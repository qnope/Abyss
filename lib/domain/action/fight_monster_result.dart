import '../fight/fight_result.dart';
import '../resource/resource_type.dart';
import '../unit/unit_type.dart';
import 'action_result.dart';

class FightMonsterResult extends ActionResult {
  final bool victory;
  final FightResult? fight;
  final Map<ResourceType, int> loot;
  final Map<UnitType, int> sent;
  final Map<UnitType, int> survivorsIntact;
  final Map<UnitType, int> wounded;
  final Map<UnitType, int> dead;

  FightMonsterResult.success({
    required this.victory,
    required this.fight,
    required this.loot,
    required this.sent,
    required this.survivorsIntact,
    required this.wounded,
    required this.dead,
  }) : super.success();

  const FightMonsterResult.failure(super.reason)
    : victory = false,
      fight = null,
      loot = const {},
      sent = const {},
      survivorsIntact = const {},
      wounded = const {},
      dead = const {},
      super.failure();
}

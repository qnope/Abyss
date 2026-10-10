import 'package:abyss/domain/action/announce_attack_action.dart';
import 'package:abyss/domain/objective/objective_migration.dart';
import 'package:abyss/domain/raid/announced_attack.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import 'base_attack_helper.dart';
import 'two_player_game.dart';

/// The rival's army, strong enough to beat a bare base.
const Map<UnitType, int> raiders = {UnitType.harpoonist: 40};

/// A two-player game at turn 12, the tutorial of the human over, the rival
/// holding [raiders] on its base.
TwoPlayerGame announceGame({int turn = 12, String rivalId = 'rival-1'}) {
  final two = assaultGame(turn: turn, rivalId: rivalId);
  ObjectiveMigration.stateOf(two.game, two.human).tutorialEnabled = false;
  station(two.rival, raiders);
  return two;
}

AnnounceAttackAction announce({
  Map<UnitType, int> army = raiders,
  int seed = 3,
}) => AnnounceAttackAction(selectedUnits: army, random: SeededRandom(seed));

List<AnnouncedAttack> pendingOf(TwoPlayerGame two) =>
    two.human.raidState.attacks;

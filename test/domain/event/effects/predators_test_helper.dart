import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import '../../raid/raid_test_helper.dart';

/// Wave of the predators waiting in the tests.
const MonsterLair predatorTestWave = MonsterLair(
  difficulty: MonsterDifficulty.easy,
  family: MonsterFamily.swarm,
  unitCount: 3,
  secondFamily: MonsterFamily.hunter,
  secondCount: 2,
);

/// [raidPlayer] whose predators, drawn at the end of turn 11 with
/// [wave], wait for a choice during turn 12.
Player threatenedPlayer({
  Map<UnitType, int> units = const {},
  int citadelLevel = 0,
  MonsterLair wave = predatorTestWave,
}) {
  final player = raidPlayer(units: units, citadelLevel: citadelLevel)
    ..eventState.schedule(100);
  player.eventState
    ..setPending(RandomEventType.predators, 12)
    ..predatorWave = wave;
  return player;
}

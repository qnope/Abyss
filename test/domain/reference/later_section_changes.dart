import 'package:abyss/domain/faction/base_intel.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/objective/tip/tip_id.dart';
import 'package:abyss/domain/raid/announced_attack.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import '../../helpers/history_entry_samples.dart';
import 'section_changes.dart';

const MonsterLair _wave = MonsterLair(
  difficulty: MonsterDifficulty.hard,
  unitCount: 4,
);

/// The changes of the sections of what happens to a player: threats,
/// objectives, scouts' reports and history.
final Map<String, List<Change>> laterSectionChanges = <String, List<Change>>{
  'raids': [
    (g) => g.humanPlayer.raidState.addNoise(3),
    (g) => g.humanPlayer.raidState.announce(_wave, 9),
    (g) => g.humanPlayer.raidState.recordOutcome(victory: false),
    (g) => g.humanPlayer.raidState.recordOutcome(victory: true),
    (g) => g.humanPlayer.raidState.kernelSiegeLostTurn = 3,
    (g) => rivalOf(g).raidState.postAttackTurns[g.humanPlayerId] = 3,
    (g) => rivalOf(g).raidState.kernelAttackTurns[g.humanPlayerId] = 3,
    (g) => g.humanPlayer.raidState.attacks.add(
      AnnouncedAttack(
        attackerId: rivalOf(g).id,
        units: {UnitType.harpoonist: 5},
        arrivalTurn: 4,
        seed: 99,
      ),
    ),
  ],
  'volcano': [
    (g) => g.humanPlayer.volcanoState.announce(_wave, 9),
    (g) => g.humanPlayer.volcanoState.recordOutcome(victory: true),
    (g) => g.humanPlayer.volcanoState.recordOutcome(victory: false),
  ],
  'events': [
    (g) => g.humanPlayer.eventState.schedule(6),
    (g) => g.humanPlayer.eventState.heating = true,
    (g) => g.humanPlayer.eventState.predatorWave = _wave,
    (g) => g.humanPlayer.eventState.wreckPosition = GridPosition(x: 1, y: 2),
    (g) => g.humanPlayer.eventState.tradeFrom = ResourceType.ore,
  ],
  'objectives': [
    (g) => g.humanPlayer.savedObjectiveState!.complete(ObjectiveId.hqLevel1),
    (g) => g.humanPlayer.savedObjectiveState!.markSeen(TipId.values.first),
    (g) => g.humanPlayer.savedObjectiveState!.tutorialEnabled = true,
    (g) => rivalOf(g).savedObjectiveState = null,
  ],
  'intel': [
    (g) =>
        rivalOf(g).intel[g.humanPlayerId] = BaseIntel(
          turn: 2,
          headquartersLevel: 1,
          rampartLevel: 0,
          army: {UnitType.scout: 2},
          stocks: {ResourceType.algae: 10},
        ),
  ],
  'history': [
    (g) => g.humanPlayer.addHistoryEntry(turnEndEntry(1)),
    (g) => rivalOf(g).addHistoryEntry(combatEntry(victory: true)),
  ],
};

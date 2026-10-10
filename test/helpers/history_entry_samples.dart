import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';

import 'transition_fight_fixtures.dart';

/// History entries of the fights, to check how they read.
const MonsterLair _lair = MonsterLair(
  difficulty: MonsterDifficulty.medium,
  unitCount: 3,
);

/// A fight against a level 2 lair.
CombatEntry combatEntry({required bool victory}) => CombatEntry(
  turn: 5,
  victory: victory,
  targetX: 3,
  targetY: 4,
  lair: _lair,
  fightResult: buildTestFight(playerWins: victory),
  loot: const {},
  sent: const {},
  survivorsIntact: const {},
  wounded: const {},
  dead: const {},
);

/// A raid on the base, or a school of predators when [surprise].
RaidEntry raidEntry({required bool victory, bool surprise = false}) =>
    RaidEntry(
      turn: 11,
      victory: victory,
      wave: _lair,
      fightResult: buildTestFight(playerWins: victory),
      loot: const {},
      pillaged: const {},
      defenders: const {},
      survivorsIntact: const {},
      wounded: const {},
      dead: const {},
      rampartLevel: 0,
      surprise: surprise,
    );

/// A kraken wave on the volcanic kernel.
VolcanoEntry volcanoEntry({required bool victory}) => VolcanoEntry(
  turn: 20,
  victory: victory,
  wave: _lair,
  fightResult: buildTestFight(playerWins: victory),
  kernelLevel: 2,
  defenders: const {},
  survivorsIntact: const {},
  wounded: const {},
  dead: const {},
);

/// The capture, won in two fight turns, of the base named [name].
CaptureEntry captureEntry(String name) => CaptureEntry(
  turn: 6,
  transitionBaseName: name,
  fightResult: buildTestFight(playerWins: true),
);

/// The end of [turn], with nothing to report.
TurnEndEntry turnEndEntry(int turn) => TurnEndEntry(
  turn: turn,
  changes: const [],
  deactivatedBuildings: const [],
  lostUnits: const {},
);

/// An assault on the base of "Nacre", seen from either side.
BaseAssaultEntry baseAssaultEntry({
  required bool victory,
  required bool defending,
}) => BaseAssaultEntry(
  turn: 14,
  victory: victory,
  defending: defending,
  opponentName: 'Nacre',
  fightResult: buildTestFight(playerWins: victory),
  units: const {},
  survivorsIntact: const {},
  wounded: const {},
  dead: const {},
  rampartBefore: 2,
  rampartAfter: 0,
  headquartersBefore: 5,
  headquartersAfter: 5,
  pillaged: const {},
  loot: const {},
);

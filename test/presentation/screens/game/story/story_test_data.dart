import 'package:abyss/domain/faction/faction_attack_report.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/exploration_order.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/raid/raid_report.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/domain/volcano/volcano_report.dart';

import '../../../../helpers/transition_fight_fixtures.dart';

/// Side of the maps of the story tests.
const storySize = 12;

/// Anchor of the volcano on level 3.
const storyKernel = (6, 4);

const storyWave =
    MonsterLair(difficulty: MonsterDifficulty.medium, unitCount: 5);

GameMap _map({bool volcano = false}) {
  final cells = List.generate(
      storySize * storySize, (_) => MapCell(terrain: TerrainType.plain));
  if (volcano) {
    cells[storyKernel.$2 * storySize + storyKernel.$1] = MapCell(
        terrain: TerrainType.plain, content: CellContentType.volcanicKernel);
  }
  return GameMap(width: storySize, height: storySize, cells: cells, seed: 1);
}

/// A game on three levels, its base on (5, 5) of level 1, where the
/// player has seen the cells around the base and sent scouts to
/// [scouts], given as (level, x, y).
Game storyGame({List<(int, int, int)> scouts = const []}) {
  final player = Player(
    name: 'Nemo',
    baseX: 5,
    baseY: 5,
    revealedCellsPerLevel: {
      1: [
        for (var y = 4; y <= 6; y++)
          for (var x = 4; x <= 6; x++) GridPosition(x: x, y: y),
      ],
    },
    pendingExplorations: [
      for (final (level, x, y) in scouts)
        ExplorationOrder(target: GridPosition(x: x, y: y), level: level),
    ],
  );
  return Game.singlePlayer(player)
    ..levels = {1: _map(), 2: _map(), 3: _map(volcano: true)};
}

/// Reveals [cells] on [level] and ends the explorations, as a turn does.
void revealAfterTurn(Game game, int level, List<(int, int)> cells) {
  final player = game.humanPlayer;
  for (final (x, y) in cells) {
    player.addRevealedCell(level, GridPosition(x: x, y: y));
  }
  player.pendingExplorations.clear();
}

RaidReport storyRaid({required bool victory}) => RaidReport(
      turn: 3,
      victory: victory,
      wave: storyWave,
      fight: buildTestFight(playerWins: victory),
      rampartLevel: 0,
      defenders: const {},
      survivorsIntact: const {},
      wounded: const {},
      dead: const {},
      loot: const {},
      pillaged: const {},
    );

VolcanoReport storyVolcano({required bool victory}) => VolcanoReport(
      turn: 3,
      victory: victory,
      wave: storyWave,
      fight: buildTestFight(playerWins: victory),
      kernelLevel: 2,
      defenders: const {},
      survivorsIntact: const {},
      wounded: const {},
      dead: const {},
    );

TurnResult storyResult({
  RaidReport? raid,
  VolcanoReport? volcano,
  List<FactionAttackReport> attacks = const [],
  FactionAttackReport? leviathan,
}) =>
    TurnResult(
      changes: const [],
      previousTurn: 3,
      newTurn: 4,
      hadRecruitedUnits: false,
      raid: raid,
      volcano: volcano,
      attacks: attacks,
      leviathan: leviathan,
    );

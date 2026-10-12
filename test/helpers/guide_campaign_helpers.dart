import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/objective/objective_catalog.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/objective/objective_state.dart';

import 'map_tab_harness.dart';
import 'objective_helpers.dart';
import 'transition_fight_fixtures.dart';

/// A fresh [objectiveGame] with plain maps on levels 1 to 3 and the
/// tutorial on, its player on the campaign objective [id]: every
/// objective before it is completed.
Game campaignGame(ObjectiveId id, {bool tutorial = true}) {
  final game =
      objectiveGame()..levels = {1: plainMap(), 2: plainMap(), 3: plainMap()};
  game.humanPlayer.savedObjectiveState = ObjectiveState(
    tutorialEnabled: tutorial,
    completed: [
      for (final objective in ObjectiveCatalog.all.takeWhile(
        (objective) => objective.id != id,
      ))
        objective.id,
    ],
  );
  return game;
}

/// Shows the cell ([x], [y]) of [level] to the human player of [game].
void reveal(Game game, int level, int x, int y) => game
    .humanPlayer
    .revealedCellsPerLevel
    .putIfAbsent(level, () => [])
    .add(GridPosition(x: x, y: y));

/// Puts a post of [type] at ([x], [y]) on [level], held by the human
/// player when [held], seen by them unless [hidden].
void placePost(
  Game game,
  int level,
  int x,
  int y, {
  TransitionBaseType type = TransitionBaseType.faille,
  bool held = false,
  bool hidden = false,
}) {
  game.levels[level]!.setCell(
    x,
    y,
    MapCell(
      terrain: TerrainType.plain,
      content: CellContentType.transitionBase,
      transitionBase: TransitionBase(
        type: type,
        name: '${type.name}:0',
        capturedBy: held ? game.humanPlayerId : null,
      ),
    ),
  );
  if (!hidden) reveal(game, level, x, y);
}

/// Puts the volcanic kernel at ([x], [y]) on level 3, seen by the human
/// player of [game] and held by them when [held].
void placeKernel(Game game, int x, int y, {bool held = false}) {
  game.levels[3]!.setCell(
    x,
    y,
    MapCell(
      terrain: TerrainType.plain,
      content: CellContentType.volcanicKernel,
      collectedBy: held ? game.humanPlayerId : null,
    ),
  );
  reveal(game, 3, x, y);
}

/// Records, on [turn], an assault on [name] won while the admiral fell.
void recordAdmiralFell(Game game, String name, {required int turn}) =>
    game.humanPlayer.historyEntries.add(
      CaptureEntry(
        turn: turn,
        transitionBaseName: name,
        fightResult: buildTestFight(playerWins: true),
        captured: false,
      ),
    );

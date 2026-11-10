import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/action/upgrade_building_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/game/victory_checker.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/timeline_script.dart';
import 'package:flutter_test/flutter_test.dart';

const _rivalId = 'faction-magmaSmiths';

/// A game where the faction holds the kernel at level 9 and can pay for
/// the last level: its next upgrade tames the volcano.
Game _gameBeforeTheRivalWins() {
  final game = GameFactory.newGame(
    playerName: 'Nemo',
    mapSeed: 5,
    personalities: const [FactionPersonality.magmaSmiths],
  );
  final Player rival = game.players[_rivalId]!;
  final GameMap deep = game.levels[3]!;
  final int kernel = deep.cells.indexWhere(
    (cell) => cell.content == CellContentType.volcanicKernel,
  );
  deep.cells[kernel] = deep.cells[kernel].copyWith(collectedBy: _rivalId);
  rival.buildings[BuildingType.headquarters]!.level = 10;
  rival.buildings[BuildingType.volcanicKernel]!.level = 9;
  for (final resource in rival.resources.values) {
    resource.amount = resource.maxStorage;
  }
  return game;
}

UpgradeBuildingAction _lastLevel() =>
    UpgradeBuildingAction(buildingType: BuildingType.volcanicKernel);

TimelineScript _replay({required Map<int, int> endTurnSeeds}) =>
    TimelineScript(
      name: 'replay',
      turns: {
        1: [(_) => _lastLevel()],
      },
      actors: const {
        1: [_rivalId],
      },
      lastTurn: 2,
      endTurnSeeds: endTurnSeeds,
    );

bool _endedTurnOne(Game game) => game.humanPlayer.historyEntries.any(
  (entry) => entry is TurnEndEntry && entry.turn == 1,
);

void main() {
  test('in a live game a faction tames the volcano while the turn ends, '
      'and the turn ends all the same', () {
    final game = _gameBeforeTheRivalWins();

    ActionExecutor().execute(
      EndTurnAction(random: SeededRandom(7)),
      game,
      game.humanPlayer,
    );

    expect(VictoryChecker.winnerOf(game)!.id, _rivalId);
    expect(game.replay!.actionsOf(1), contains(containsPair('building', 'volcanicKernel')));
    expect(game.status, GameStatus.defeat);
    expect(game.turn, 2);
    expect(_endedTurnOne(game), isTrue);
  });

  test('its replay, which plays the move of the faction before ending '
      'the turn, ends that turn too: the journal holds its seed', () {
    final game = _gameBeforeTheRivalWins();

    ScriptRunner().runOn(
      game,
      _replay(endTurnSeeds: const {1: 7}),
      random: Random(1),
      seed: 1,
    );

    expect(game.status, GameStatus.defeat);
    expect(game.turn, 2);
    expect(_endedTurnOne(game), isTrue);
    expect(game.replay!.endTurnSeeds, {1: 7});
  });

  test('a timeline that recorded no end for that turn stops there', () {
    final game = _gameBeforeTheRivalWins();

    ScriptRunner().runOn(
      game,
      _replay(endTurnSeeds: const {}),
      random: Random(1),
      seed: 1,
    );

    expect(game.status, GameStatus.defeat);
    expect(game.turn, 1);
    expect(_endedTurnOne(game), isFalse);
  });

  test('a game the human wins still stops on the winning move', () {
    final game = _gameBeforeTheRivalWins();
    final human = game.humanPlayer;
    final rival = game.players[_rivalId]!;
    final GameMap deep = game.levels[3]!;
    final int kernel = deep.cells.indexWhere(
      (cell) => cell.content == CellContentType.volcanicKernel,
    );
    deep.cells[kernel] = deep.cells[kernel].copyWith(collectedBy: human.id);
    for (final type in [BuildingType.headquarters, BuildingType.volcanicKernel]) {
      human.buildings[type]!.level = rival.buildings[type]!.level;
    }
    for (final resource in human.resources.values) {
      resource.amount = resource.maxStorage;
    }

    ScriptRunner().runOn(
      game,
      TimelineScript(
        name: 'replay',
        turns: {
          1: [(_) => _lastLevel()],
        },
        endTurnSeeds: const {1: 7},
      ),
      random: Random(1),
      seed: 1,
    );

    expect(game.status, GameStatus.victory);
    expect(game.turn, 1);
  });
}

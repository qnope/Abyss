import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/objective/installation_objectives.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/raid/raid_wave_factory.dart';
import 'package:abyss/domain/script/game_script.dart';
import 'package:abyss/domain/script/script_library.dart';
import 'package:abyss/domain/script/script_log_entry.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/conquest_strategy.dart';
import 'package:abyss/domain/script/strategies/tutorial_strategy.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

Game _game() =>
    GameFactory.newSinglePlayer(playerName: 'p', mapSeed: 5, tutorial: true);

/// Plays [turns] turns of [game] with [script]; returns the log.
List<ScriptLogEntry> _play(GameScript script, Game game, int turns) {
  final Random random = Random(1);
  final List<ScriptLogEntry> log = <ScriptLogEntry>[];
  for (int i = 0; i < turns; i++) {
    script.playTurn(ScriptTurn(game: game, random: random, log: log));
    ActionExecutor().execute(
        EndTurnAction(random: random), game, game.humanPlayer);
  }
  return log;
}

void main() {
  test('reaches the objectives of the first chapter one after the other', () {
    final Game game = _game();

    _play(const TutorialStrategy(), game, 12);

    final completed = game.humanPlayer.savedObjectiveState!.completed;
    expect(completed.take(8), <ObjectiveId>[
      for (final objective in installationObjectives.take(8)) objective.id,
    ]);
  });

  test('builds nothing the tutorial does not ask for', () {
    final Game game = _game();

    _play(const TutorialStrategy(), game, 9);

    final buildings = game.humanPlayer.buildings;
    expect(buildings[BuildingType.coralCitadel]!.level, 0);
    expect(buildings[BuildingType.headquarters]!.level, lessThanOrEqualTo(2));
    expect(buildings[BuildingType.algaeFarm]!.level, lessThanOrEqualTo(1));
  });

  test('recruits defenders for a raid announced during the tutorial', () {
    final Game game = _game();
    _play(const TutorialStrategy(), game, 7);
    final player = game.humanPlayer;
    expect(player.buildings[BuildingType.barracks]!.level, 1);
    player.raidState.announce(
        RaidWaveFactory.fromTotalNoise(40, random: Random(1)),
        game.turn + 2);

    _play(const TutorialStrategy(), game, 1);

    expect(player.unitsOnLevel(1)[UnitType.harpoonist]!.count, greaterThan(0));
  });

  test('plays like the careful script once the first raid is fought', () {
    final Game tutorial = _game()..humanPlayer.raidState.raidsRepelled = 1;
    final Game conquest = _game()..humanPlayer.raidState.raidsRepelled = 1;

    final played = _play(const TutorialStrategy(), tutorial, 6);
    final expected = _play(const ConquestStrategy(), conquest, 6);

    expect(played.map((e) => e.description),
        expected.map((e) => e.description));
  });

  test('is a strategy of the library', () {
    expect(ScriptLibrary.byName('tutorial').name, 'tutorial');
  });
}

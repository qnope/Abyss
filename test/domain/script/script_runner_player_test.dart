import 'dart:convert';
import 'dart:math';

import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/script/script_library.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/strategies/economy_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/two_player_game.dart';

// Captured from the runner before it could play any player.
const String _conquestSeed1Turn30 =
    '{"script":"conquest","seed":1,"status":"playing","turnsPlayed":30,'
    '"raidsRepelled":4,"raidsLost":1,"monstersDefeated":17,"totalNoise":314,'
    '"failedActions":0,"buildings":{"headquarters":7,"algaeFarm":4,'
    '"coralMine":4,"oreExtractor":4,"solarPanel":4,"laboratory":4,'
    '"barracks":3,"coralCitadel":1,"descentModule":0,"pressureCapsule":0,'
    '"volcanicKernel":0},"baseUnits":{"scout":0,"harpoonist":26,'
    '"guardian":4,"domeBreaker":0,"abyssAdmiral":1,"saboteur":0},'
    '"resources":{"algae":5000,"coral":1560,"ore":1973,"energy":202,'
    '"pearl":11},"failleCaptured":null,"chemineeCaptured":null,'
    '"kernelCaptured":null,"raids":[{"turn":13,"monsters":26,"level":1,'
    '"victory":false},{"turn":20,"monsters":52,"level":1,"victory":true},'
    '{"turn":23,"monsters":16,"level":2,"victory":true},{"turn":25,'
    '"monsters":50,"level":2,"victory":true},{"turn":28,"monsters":31,'
    '"level":3,"victory":true}]}';

void main() {
  test('the human conquest of seed 1 still reports the same 30 turns', () {
    final report = ScriptRunner(
      maxTurns: 30,
    ).run(ScriptLibrary.byName('conquest'), seed: 1);

    expect(jsonEncode(report.toJson()), _conquestSeed1Turn30);
  });

  test('a runner plays a strategy for the second player of a game', () {
    final two = TwoPlayerGame.create();
    final humanLevels = {
      for (final e in two.human.buildings.entries) e.key: e.value.level,
    };

    final report = ScriptRunner(maxTurns: 5).runOn(
      two.game,
      const EconomyStrategy(),
      random: Random(1),
      seed: 1,
      playerId: two.rival.id,
    );

    expect(report.status, GameStatus.playing);
    expect(report.buildings, {
      for (final e in two.rival.buildings.entries) e.key: e.value.level,
    });
    expect({
      for (final e in two.human.buildings.entries) e.key: e.value.level,
    }, humanLevels);
  });

  test('a rival report counts the resources of the rival', () {
    final two = TwoPlayerGame.create();
    two.human.resources[ResourceType.algae]!.amount += 100000;

    final report = ScriptRunner(maxTurns: 3).runOn(
      two.game,
      const EconomyStrategy(),
      random: Random(1),
      seed: 1,
      playerId: two.rival.id,
    );

    expect(report.statistics.totalResourcesCollected, lessThan(100000));
  });
}

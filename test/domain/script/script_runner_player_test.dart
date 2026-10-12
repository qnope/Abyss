import 'dart:convert';
import 'dart:math';

import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/script/script_library.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/strategies/economy_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/two_player_game.dart';

// Captured from the runner before it could play any player; recaptured
// when the tutorial gained its Solar Panel level 2 step.
const String _conquestSeed1Turn30 =
    '{"script":"conquest","seed":1,"status":"playing","turnsPlayed":30,'
    '"raidsRepelled":4,"raidsLost":2,"monstersDefeated":0,"totalNoise":'
    '320,"failedActions":0,"buildings":{"headquarters":7,"algaeFarm":4,'
    '"coralMine":4,"oreExtractor":4,"solarPanel":4,"laboratory":3,"barr'
    'acks":3,"coralCitadel":0,"descentModule":0,"pressureCapsule":0,"vo'
    'lcanicKernel":0},"baseUnits":{"scout":0,"harpoonist":3,"guardian":'
    '0,"domeBreaker":0,"abyssAdmiral":1,"saboteur":0},"resources":{"alg'
    'ae":5000,"coral":713,"ore":2047,"energy":355,"pearl":10},"failleCa'
    'ptured":null,"chemineeCaptured":null,"kernelCaptured":null,"leviat'
    'hanStruck":null,"leviathanHeld":null,"raids":[{"turn":13,"monsters'
    '":26,"level":1,"victory":false},{"turn":20,"monsters":20,"level":1'
    ',"victory":true},{"turn":22,"monsters":38,"level":2,"victory":true'
    '},{"turn":25,"monsters":14,"level":2,"victory":false},{"turn":27,"'
    'monsters":15,"level":2,"victory":true},{"turn":29,"monsters":34,"l'
    'evel":3,"victory":true}],"waves":[]}';

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

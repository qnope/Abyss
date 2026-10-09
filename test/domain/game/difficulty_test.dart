import 'dart:math';

import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/raid/raid_wave_factory.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/volcano/volcano_wave_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normal changes nothing', () {
    final production = <ResourceType, int>{ResourceType.coral: 120};
    expect(
      Difficulty.normal.scaleProduction(production)[ResourceType.coral],
      120,
    );
    expect(Difficulty.normal.monsters(40), 40);
  });

  test('easy gives more resources and fewer monsters than hard', () {
    expect(
      Difficulty.easy.resourcePercent,
      greaterThan(Difficulty.normal.resourcePercent),
    );
    expect(
      Difficulty.hard.resourcePercent,
      lessThan(Difficulty.normal.resourcePercent),
    );
    expect(
      Difficulty.easy.monsterPercent,
      lessThan(Difficulty.normal.monsterPercent),
    );
    expect(
      Difficulty.hard.monsterPercent,
      greaterThan(Difficulty.normal.monsterPercent),
    );
  });

  test('only algae, coral and ore are scaled', () {
    final production = Difficulty.easy.scaleProduction(<ResourceType, int>{
      ResourceType.algae: 100,
      ResourceType.coral: 100,
      ResourceType.ore: 100,
      ResourceType.energy: 100,
      ResourceType.pearl: 5,
    });
    final int scaled = Difficulty.easy.resourcePercent;
    expect(production[ResourceType.algae], scaled);
    expect(production[ResourceType.coral], scaled);
    expect(production[ResourceType.ore], scaled);
    expect(production[ResourceType.energy], 100);
    expect(production[ResourceType.pearl], 5);
  });

  test('a scaled wave keeps at least one monster', () {
    expect(Difficulty.easy.monsters(1), 1);
  });

  test('raid waves grow with the difficulty', () {
    int monstersOf(Difficulty d) {
      final wave = RaidWaveFactory.fromTotalNoise(
        200,
        random: Random(3),
        difficulty: d,
      );
      return wave.unitCount + wave.secondCount;
    }

    expect(
      monstersOf(Difficulty.easy),
      lessThan(monstersOf(Difficulty.normal)),
    );
    expect(
      monstersOf(Difficulty.hard),
      greaterThan(monstersOf(Difficulty.normal)),
    );
  });

  test('kraken waves grow with the difficulty', () {
    int krakens(Difficulty d) =>
        VolcanoWaveFactory.fromKernelLevel(9, difficulty: d).unitCount;
    expect(krakens(Difficulty.easy), lessThan(krakens(Difficulty.normal)));
    expect(krakens(Difficulty.hard), greaterThan(krakens(Difficulty.normal)));
  });

  test('a new game starts in the difficulty picked', () {
    final game = GameFactory.newSinglePlayer(
      playerName: 'Nemo',
      mapSeed: 1,
      difficulty: Difficulty.hard,
    );
    expect(game.difficulty, Difficulty.hard);
    expect(
      GameFactory.newSinglePlayer(playerName: 'Nemo', mapSeed: 1).difficulty,
      Difficulty.normal,
    );
  });
}

import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/raid/raid_wave_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('weak waves have at least 5 level 1 monsters', () {
    final wave = RaidWaveFactory.fromTotalNoise(10);
    expect(wave.difficulty, MonsterDifficulty.easy);
    expect(wave.unitCount, 5);
  });

  test('one level 1 monster per 5 noise below 150 noise', () {
    final wave = RaidWaveFactory.fromTotalNoise(100);
    expect(wave.difficulty, MonsterDifficulty.easy);
    expect(wave.unitCount, 20);
  });

  test('level 2 monsters from 150 noise, costing 2 power each', () {
    final wave = RaidWaveFactory.fromTotalNoise(200);
    expect(wave.difficulty, MonsterDifficulty.medium);
    expect(wave.unitCount, 20);
  });

  test('level 3 monsters from 400 noise, costing 4 power each', () {
    final wave = RaidWaveFactory.fromTotalNoise(400);
    expect(wave.difficulty, MonsterDifficulty.hard);
    expect(wave.unitCount, 20);
  });
}

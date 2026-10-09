import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/raid/raid_wave_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('weak waves have at least 5 level 1 monsters', () {
    final wave = RaidWaveFactory.fromTotalNoise(10);
    expect(wave.difficulty, MonsterDifficulty.easy);
    expect(wave.unitCount, 5);
  });

  test('42 power per 100 noise, one level 1 monster per power below 30',
      () {
    final wave = RaidWaveFactory.fromTotalNoise(50);
    expect(wave.difficulty, MonsterDifficulty.easy);
    expect(wave.unitCount, 21);
  });

  test('level 2 monsters from 30 power, costing 2 power each', () {
    expect(RaidWaveFactory.fromTotalNoise(71).difficulty,
        MonsterDifficulty.easy);
    expect(RaidWaveFactory.fromTotalNoise(72).difficulty,
        MonsterDifficulty.medium);
    final wave = RaidWaveFactory.fromTotalNoise(150);
    expect(wave.difficulty, MonsterDifficulty.medium);
    expect(wave.unitCount, 31);
  });

  test('level 3 monsters from 80 power, costing 4 power each', () {
    final wave = RaidWaveFactory.fromTotalNoise(400);
    expect(wave.difficulty, MonsterDifficulty.hard);
    expect(wave.unitCount, 42);
  });
}

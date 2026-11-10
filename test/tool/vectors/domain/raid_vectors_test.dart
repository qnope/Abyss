import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/vectors/domain/raid_cases.dart';
import '../../../../tool/vectors/domain/raid_vectors.dart';
import 'vector_reader.dart';

void main() {
  final vectors = VectorReader(RaidVectors.file);
  final difficulties = {for (final d in MonsterDifficulty.values) d.name};

  group('RaidVectors', () {
    test('send waves of every difficulty, two families each', () {
      final waves = vectors.outs('wave').cast<List<Object?>>();
      expect(waves, hasLength(RaidCases.waves.length * RaidCases.seeds.length));
      expect({for (final w in waves) w[0]}, difficulties);
      expect({for (final w in waves) w[1]}.length, greaterThan(3));
      for (final w in waves) {
        expect(w, hasLength(5));
        expect(w[3], isNot(w[1]));
      }
      expect({for (final w in waves) '$w'}.length, greaterThan(60));
    });

    test('let a strong garrison set the wave by itself', () {
      final cases = vectors.cases('wave');
      final quiet = cases.where((c) => c['noise'] == 0 && c['defence'] == 0);
      final guarded = cases.where((c) => c['noise'] == 0 && c['defence'] != 0);
      expect({for (final c in quiet) (c['out']! as List)[0]}, {'easy'});
      expect({for (final c in guarded) (c['out']! as List)[0]}, {'hard'});
    });

    test('list every wave a noise can send', () {
      for (final List<Object?> waves in vectors.outs('everyWave').cast()) {
        expect({for (final w in waves) '$w'}, hasLength(waves.length));
        expect(waves.length, greaterThanOrEqualTo(6));
      }
    });

    test('weigh the garrison of a base', () {
      final strengths = vectors.outs('defenceStrength').cast<int>();
      expect(strengths.first, 0);
      expect(strengths, hasLength(RaidCases.garrisons.length));
      expect(strengths.toSet().length, greaterThan(3));
    });

    test('take a loot, capped by what the base produces', () {
      expect(vectors.valuesOf('loot', 'difficulty'), difficulties);
      var capped = 0;
      for (final c in vectors.cases('loot')) {
        if ('${c['capped']}' != '${c['out']}') capped++;
      }
      expect(capped, greaterThan(0));
      final pillages = vectors.outs('pillage').cast<Map<String, Object?>>();
      expect(pillages.where((p) => (p['taken']! as Map).isEmpty), isNotEmpty);
      expect(
        {for (final p in pillages) '${p['taken']}'}.length,
        greaterThan(6),
      );
    });

    test('count the krakens of every kernel level', () {
      expect(vectors.valuesOf('krakens', 'level'), hasLength(11));
      expect(vectors.valuesOf('krakens', 'firstWave'), {true, false});
      expect(vectors.outs('krakens').toSet().length, greaterThan(8));
    });

    test('scale the monsters for every difficulty and world', () {
      expect(vectors.valuesOf('monsterPercent', 'difficulty'), {
        for (final d in Difficulty.values) d.name,
      });
      for (final Map<Object?, Object?> o
          in vectors.outs('monsterPercent').cast()) {
        expect(o['human'], hasLength(11));
        expect((o['human']! as List).toSet().length, greaterThan(8));
      }
      expect(vectors.outs('upgradeNoise').toSet().length, greaterThan(2));
    });
  });
}

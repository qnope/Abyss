import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/vectors/domain/fight_aftermath_vectors.dart';
import 'vector_reader.dart';

void main() {
  final vectors = VectorReader(FightAftermathVectors.file);

  group('FightAftermathVectors', () {
    test('follow the wounded curve on both sides of its bends', () {
      final curve = {
        for (final c in vectors.cases('woundedProbability'))
          VectorReader.number(c['pctLost']): VectorReader.number(c['out']),
      };
      expect(curve.keys, containsAll([0, 0.5, 0.8, 1]));
      expect(curve.keys.where((p) => p > 0.5 && p < 0.501), isNotEmpty);
      expect(curve.keys.where((p) => p > 0.799 && p < 0.8), isNotEmpty);
      expect(curve.values.toSet().length, greaterThan(10));
      for (final double probability in curve.values) {
        expect(probability, inInclusiveRange(0, 1));
      }
    });

    test('measure the hit points lost, none to all', () {
      final lost = [
        for (final o in vectors.outs('pctLost')) VectorReader.number(o),
      ];
      expect(lost, containsAll([0, 1]));
      expect(lost.where((p) => p > 0 && p < 1), isNotEmpty);
    });

    test('split the fallen between wounded and dead, in order', () {
      var both = 0;
      for (final c in vectors.cases('casualties')) {
        final out = c['out']! as Map<String, Object?>;
        final List<Object?> wounded = out['wounded']! as List<Object?>;
        final List<Object?> dead = out['dead']! as List<Object?>;
        final fallen = c['fallen']! as List<Object?>;
        expect(wounded.length + dead.length, fallen.length);
        expect(dead, isNot(contains('scout')));
        if (wounded.isNotEmpty && dead.isNotEmpty) both++;
      }
      expect(both, greaterThan(10));
      expect(
        {for (final c in vectors.cases('casualties')) '${c['out']}'}.length,
        greaterThan(15),
      );
    });

    test('loot every lair difficulty and every treasure', () {
      expect(vectors.valuesOf('lairLoot', 'difficulty'), {
        for (final d in MonsterDifficulty.values) d.name,
      });
      expect({for (final o in vectors.outs('lairLoot')) '$o'}, hasLength(18));
      expect(vectors.valuesOf('treasureLoot', 'level'), {1, 2, 3});
      expect(vectors.valuesOf('treasureLoot', 'content').length, greaterThan(2));
      final loots = vectors.outs('treasureLoot').cast<Map<String, Object?>>();
      expect(loots.where((l) => l.isEmpty), isNotEmpty);
      expect({for (final l in loots) '$l'}.length, greaterThan(20));
    });
  });
}

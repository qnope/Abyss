import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/vectors/domain/faction_vectors.dart';
import 'vector_reader.dart';

void main() {
  final vectors = VectorReader(FactionVectors.file);
  final personalities = {for (final p in FactionPersonality.values) p.name};

  group('FactionVectors', () {
    test('draw one, three and every faction, never the same twice', () {
      for (final c in vectors.cases('draw')) {
        final List<Object?> drawn = c['out']! as List<Object?>;
        expect(drawn, hasLength(c['count']! as int));
        expect(drawn.toSet(), hasLength(drawn.length));
      }
      expect(
        {
          for (final c in vectors.cases('draw'))
            if (c['count'] == 10) '${c['out']}',
        }.length,
        greaterThan(3),
      );
    });

    test('describe every personality', () {
      expect(vectors.valuesOf('traits', 'personality'), personalities);
      final traits = vectors.outs('traits').cast<Map<String, Object?>>();
      for (final String key in traits.first.keys) {
        if (key == 'label' || key == 'defends') continue;
        expect(
          {for (final t in traits) '${t[key]}'}.length,
          greaterThan(1),
          reason: 'every personality has the same $key',
        );
      }
      expect({for (final t in traits) t['label']}, hasLength(traits.length));
      for (final t in traits) {
        expect(t['shares'], hasLength(30));
        // The order of a war mix is the order its units fight in.
        expect(t['warMix'], isA<List<Object?>>());
      }
    });

    test('tell the turns each personality strikes on', () {
      expect(vectors.valuesOf('slots', 'personality'), personalities);
      final slots = vectors.outs('slots').cast<Map<String, Object?>>();
      expect({for (final s in slots) '${s['due']}'}.length, greaterThan(2));
      expect({for (final s in slots) '${s['offSlot']}'}.length, greaterThan(1));
      for (final s in slots) {
        expect(s['due'], containsAll(s['grudge']! as List<Object?>));
      }
    });

    test('lower the confidence of a siege as the kernel heats', () {
      final cases = vectors.cases('siege');
      expect(vectors.valuesOf('siege', 'hot'), {true, false});
      final changed = cases.where(
        (c) => (c['out']! as List)[1] != c['confidence'],
      );
      expect(changed, isNotEmpty);
      expect(changed.length, lessThan(cases.length));
      expect(vectors.valuesOf('siegesPerTurn', 'difficulty'), {
        for (final d in Difficulty.values) d.name,
      });
    });

    test('bias the exploration around bases on the three map sizes', () {
      expect(vectors.valuesOf('explorationBias', 'size'), containsAll([20, 26, 32]));
      for (final c in vectors.cases('explorationBias')) {
        final biases = [
          for (final b in c['out']! as List<Object?>) VectorReader.number(b),
        ];
        expect(biases, hasLength((c['targets']! as List).length));
        expect(biases.toSet().length, greaterThan(8));
        expect(biases.where((b) => b < 0), isNotEmpty);
      }
      final signs = {
        for (final c in vectors.cases('explorationBias'))
          for (final b in c['out']! as List<Object?>)
            VectorReader.number(b).sign,
      };
      expect(signs, {-1, 0, 1});
    });
  });
}

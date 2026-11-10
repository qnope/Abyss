import 'package:abyss/domain/event/random_event_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/vectors/domain/event_vectors.dart';
import 'vector_reader.dart';

void main() {
  final vectors = VectorReader(EventVectors.file);

  group('EventVectors', () {
    test('draw the turn of the first event and of the next ones', () {
      final draws = vectors.cases('drawTurns');
      expect(draws, hasLength(7 * EventVectors.seeds.length));
      for (final c in draws) {
        final List<int> out = (c['out']! as List).cast<int>();
        expect(out, hasLength(2));
        expect(out[1], greaterThan(c['turn']! as int));
      }
      expect({for (final c in draws) '${c['out']}'}.length, greaterThan(20));
    });

    test('pick every event, and none when all are excluded', () {
      final picked = vectors.outs('pick').toSet();
      expect(picked, {
        null,
        for (final type in RandomEventType.values) type.name,
      });
      for (final c in vectors.cases('pick')) {
        expect(c['excluded'], isNot(contains(c['out'])));
        expect(c['next'], inInclusiveRange(0, 999));
      }
      expect(vectors.valuesOf('pick', 'lastDrawn'), hasLength(3));
    });

    test('count the survivors as the game goes on', () {
      final counts = vectors.outs('survivors').cast<int>();
      expect(counts.toSet().length, greaterThan(3));
      expect(counts, [...counts]..sort());
    });

    test('change the production while a current or a storm lasts', () {
      final cases = vectors.cases('production');
      expect(vectors.valuesOf('production', 'active'), {
        null, 'warmCurrent', 'coldCurrent', 'storm',
      });
      final percents = {
        for (final c in cases)
          ...((c['out']! as Map)['percents']! as Map).values,
      };
      expect(percents.length, greaterThan(2));
      expect(
        cases.where((c) => (c['out']! as Map)['heatingEnergy'] != 0),
        isNotEmpty,
      );
      // Past its last turn an event changes nothing.
      for (final c in cases.where((c) => c['turn'] == 11)) {
        expect((c['out']! as Map)['adjusted'], c['production']);
      }
    });
  });
}

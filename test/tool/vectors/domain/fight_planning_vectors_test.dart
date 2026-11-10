import 'package:abyss/domain/fight/assault/assault_target.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/vectors/domain/fight_planning_cases.dart';
import '../../../../tool/vectors/domain/fight_planning_vectors.dart';
import 'vector_reader.dart';

void main() {
  final vectors = VectorReader(FightPlanningVectors.file);
  List<Map<String, Object?>> outs(String section) =>
      vectors.outs(section).cast<Map<String, Object?>>();

  group('FightPlanningVectors', () {
    test('weigh both sides of every fight, an empty one included', () {
      final strengths = [
        for (final List<Object?> pair in vectors.outs('strength').cast())
          for (final s in pair) VectorReader.number(s),
      ];
      expect(strengths.where((s) => s.isInfinite), isNotEmpty);
      expect(strengths.where((s) => s == 0), isNotEmpty);
      expect(strengths.where((s) => s > 0 && s.isFinite).toSet().length,
          greaterThan(30));
    });

    test('rehearse lost, won and undecided fights', () {
      final rehearsed = outs('rehearsal');
      expect(rehearsed.where((o) => o['hopeless'] == true), isNotEmpty);
      final twenty = [
        for (final c in vectors.cases('rehearsal'))
          if (c['rehearsals'] == 20) (c['out']! as Map)['wins']! as int,
      ];
      expect(twenty, containsAll([0, 20]));
      expect(twenty.where((w) => w > 0 && w < 20).length, greaterThan(2));
      expect(vectors.valuesOf('rehearsal', 'needsAdmiral'), {true, false});
    });

    test('stop counting once the wins needed are out of reach', () {
      var cutShort = 0;
      for (final o in outs('rehearsal')) {
        final List<int> needing = (o['winsNeeding']! as List).cast<int>();
        final int wins = o['wins']! as int;
        for (var n = 0; n < needing.length; n++) {
          expect(needing[n] >= n, wins >= n);
          if (needing[n] != wins) cutShort++;
        }
      }
      expect(cutShort, greaterThan(0));
    });

    test('plan with several confidences, one out of reach', () {
      final cases = vectors.cases('planner');
      expect(
        {for (final c in cases) VectorReader.number(c['confidence'])},
        containsAll([0.625, 0.85, 1.1]),
      );
      final planned = outs('planner');
      expect({for (final o in planned) o['wins']}, {true, false});
      final added = {
        for (final o in planned) ...(o['smallestWinning']! as List),
      };
      expect(added, containsAll([null, 0]));
      expect(added.whereType<int>().where((k) => k > 0), isNotEmpty);
      for (final o in planned) {
        expect(o['smallestWinning'], hasLength(FightPlanningCases.maxKs.length));
      }
    });

    test('rate an assault on each target, low to high', () {
      expect(vectors.valuesOf('assaultChance', 'target'), {
        for (final target in AssaultTarget.values) target.name,
      });
      final chances = outs('assaultChance');
      expect({for (final o in chances) o['rating']}.length, greaterThan(2));
      expect(chances.where((o) => o['harpoonists'] == null), isNotEmpty);
      expect(chances.where((o) => o['harpoonists'] == 0), isNotEmpty);
      expect(
        chances.where((o) => ((o['harpoonists'] ?? 0) as int) > 0),
        isNotEmpty,
      );
      expect(
        {for (final o in outs('assaultRating')) o['rating']},
        {for (final o in chances) o['rating']},
      );
    });
  });
}

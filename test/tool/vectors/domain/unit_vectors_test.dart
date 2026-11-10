import 'package:abyss/domain/fight/unit_boost.dart';
import 'package:abyss/domain/unit/unit_stats.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/vectors/domain/unit_vectors.dart';
import 'vector_reader.dart';

void main() {
  final vectors = VectorReader(UnitVectors.file);
  final types = {for (final t in UnitType.values) t.name};

  group('UnitVectors', () {
    test('describe every unit', () {
      expect(vectors.valuesOf('units', 'type'), types);
      final scout = vectors.cases('units').first['out']! as Map;
      expect(scout['costDegraded'], isNot(scout['cost']));
    });

    test('boost every stat a unit has by every percent of the research', () {
      final stats = {
        for (final type in UnitType.values)
          for (final s in [UnitStats.forType(type)]) ...[s.hp, s.atk, s.def],
      };
      expect(UnitVectors.stats.toSet().containsAll(stats), isTrue);
      expect(UnitVectors.percents, containsAll([0, 35, 60, 95, 130]));
    });

    test('round a boosted half away from zero', () {
      final halves = [
        for (final c in vectors.cases('boost'))
          for (final int stat in (c['stats']! as List).cast())
            if (stat * (100 + (c['percent']! as int)) % 100 == 50)
              (c['percent']! as int, stat),
      ];
      expect(halves, isNotEmpty);
      for (final (int percent, int stat) in halves) {
        expect(
          UnitBoost(atkPercent: percent).atk(stat),
          (stat * (100 + percent) + 50) ~/ 100,
        );
      }
    });

    test('count the units a stock recruits, barracks whole or degraded', () {
      expect(vectors.valuesOf('maxRecruitable', 'type'), types);
      expect(vectors.valuesOf('maxRecruitable', 'degraded'), {true, false});
      expect(vectors.outs('maxRecruitable').toSet().length, greaterThan(8));
    });

    test('starve some armies and feed others', () {
      final losses = vectors.outs('hungerLosses').cast<Map<String, Object?>>();
      expect(losses.where((l) => l.isEmpty), isNotEmpty);
      expect(losses.where((l) => l.length > 2), isNotEmpty);
      final all = vectors.outs('hungerLossesAllLevels').cast<Map>();
      expect(all.where((o) => (o['losses']! as Map).isNotEmpty), isNotEmpty);
      for (final o in all) {
        expect(o['left'], hasLength(2));
      }
    });
  });
}

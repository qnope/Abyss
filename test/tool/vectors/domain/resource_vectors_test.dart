import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/resource/production_formulas.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/vectors/domain/resource_vectors.dart';
import 'vector_reader.dart';

void main() {
  final vectors = VectorReader(ResourceVectors.file);

  group('ResourceVectors', () {
    test('give what every production building yields at every level', () {
      expect(vectors.valuesOf('buildingProduction', 'type'), {
        for (final type in productionFormulas.keys) type.name,
      });
      expect(vectors.valuesOf('buildingProduction', 'level'), hasLength(12));
    });

    test('produce with and without research, on whole and degraded bases', () {
      final cases = vectors.cases('production');
      expect(cases.where((c) => c['tech'] == null), isNotEmpty);
      expect(cases.where((c) => (c['tech'] as Map?)?.isNotEmpty ?? false),
          isNotEmpty);
      // The same buildings but the headquarters produce less under them.
      final byBuildings = <String, Object?>{};
      for (final c in cases.where((c) => c['tech'] == null)) {
        final levels = Map<String, Object?>.of(c['buildings']! as Map<String, Object?>)
          ..remove('headquarters');
        byBuildings.putIfAbsent('$levels', () => c['out']);
        if ('${byBuildings['$levels']}' != '${c['out']}') return;
      }
      fail('no base produces less once its headquarters fell');
    });

    test('scale a production for each difficulty, humans and factions', () {
      final scaled = vectors.cases('production').last['scaled']! as Map;
      expect(scaled.keys, ['easy', 'hard', 'normal']);
      expect({for (final s in scaled.values) '$s'}, hasLength(3));
      final List<Object?> easy = scaled['easy']! as List<Object?>;
      expect(easy, hasLength(2));
      expect(easy[0], isNot(easy[1]));
    });

    test('count the energy of every building', () {
      expect(vectors.valuesOf('energyConsumption', 'type'), {
        for (final type in BuildingType.values) type.name,
      });
      expect(vectors.outs('energyConsumption').toSet().length, greaterThan(5));
      final totals = vectors.cases('totalConsumption');
      expect(totals.where((c) => c['excluded'] != null), isNotEmpty);
      expect(totals.map((c) => c['out']).toSet().length, greaterThan(3));
    });

    test('store every resource, the default storage included', () {
      expect(vectors.valuesOf('storage', 'type'), {
        for (final type in ResourceType.values) type.name,
      });
      expect(vectors.valuesOf('storage', 'asked'), contains(isNull));
      expect(vectors.cases('startingStocks').single['out'], hasLength(5));
    });

    test('credit stocks up to their storage', () {
      var capped = 0;
      for (final c in vectors.cases('credit')) {
        final asked = {
          for (final List<Object?> pair in (c['amounts']! as List).cast())
            pair[0]: pair[1],
        };
        final added = (c['out']! as Map)['added']! as Map;
        if ('$asked' != '$added') capped++;
      }
      expect(capped, greaterThan(0));
      expect(capped, lessThan(vectors.cases('credit').length));
    });
  });
}

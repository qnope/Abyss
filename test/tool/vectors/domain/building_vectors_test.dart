import 'package:abyss/domain/building/building_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/vectors/domain/building_vectors.dart';
import 'vector_reader.dart';

void main() {
  final vectors = VectorReader(BuildingVectors.file);
  final types = {for (final t in BuildingType.values) t.name};

  group('BuildingVectors', () {
    test('grow every base cost over ten levels', () {
      final cases = vectors.cases('exponentialCost');
      expect(cases, hasLength(BuildingVectors.bases.length * 10));
      expect(vectors.valuesOf('exponentialCost', 'step'), hasLength(10));
      // The factor itself is left out: its last bit is the C library's.
      expect(cases.first.keys, ['base', 'out', 'step']);
    });

    test('grow by 8/5 a level exactly: a port needs no pow', () {
      for (final c in vectors.cases('exponentialCost')) {
        final int step = c['step']! as int;
        final BigInt five = BigInt.from(5).pow(step);
        final BigInt eight = BigInt.from(8).pow(step);
        final base = (c['base']! as Map<String, Object?>).cast<String, int>();
        expect(c['out'], {
          for (final e in base.entries)
            e.key:
                ((BigInt.two * BigInt.from(e.value) * eight + five) ~/
                        (BigInt.two * five))
                    .toInt(),
        }, reason: '$c');
      }
    });

    test('cost every building at every level, discounted or not', () {
      expect(vectors.valuesOf('upgradeCost', 'type'), types);
      expect(vectors.valuesOf('upgradeCost', 'discount'), {0, 7, 15});
      final limits = {
        for (final c in vectors.cases('limits'))
          c['type']: (c['out']! as Map<String, Object?>)['maxLevel']! as int,
      };
      expect(limits.keys.toSet(), types);
      for (final c in vectors.cases('upgradeCost')) {
        final int level = c['level']! as int;
        expect(level, lessThanOrEqualTo(limits[c['type']]!));
        expect(c['out'], level == limits[c['type']] ? isEmpty : isNotEmpty);
      }
      final full = vectors.cases('upgradeCost').firstWhere(
        (c) => c['type'] == 'laboratory' && c['level'] == 3,
      );
      final cheap = vectors.cases('upgradeCost').firstWhere(
        (c) =>
            c['type'] == 'laboratory' && c['level'] == 3 && c['discount'] == 15,
      );
      expect(cheap['out'], isNot(full['out']));
    });

    test('ask for prerequisites and captured posts', () {
      final outs = vectors.outs('limits').cast<Map<String, Object?>>();
      expect(outs.where((o) => o['capturedBase'] != null), isNotEmpty);
      expect(outs.where((o) => o['capturedKernel'] == true), isNotEmpty);
      for (final o in outs) {
        expect(o['prerequisites'], hasLength((o['maxLevel']! as int) + 2));
      }
    });

    test('tell which buildings outgrew the headquarters', () {
      final outs = vectors.outs('degradation').cast<Map<String, Object?>>();
      final missing = [
        for (final o in outs) ...(o['missing']! as Map<String, Object?>).values,
      ];
      expect(missing, contains(isNull));
      expect(missing, contains(isA<int>()));
      expect(outs.where((o) => (o['deactivated']! as List).isEmpty), isNotEmpty);
      expect(
        outs.where((o) => (o['deactivated']! as List).isNotEmpty),
        isNotEmpty,
      );
    });

    test('build the rampart of each level, whole and degraded', () {
      final cases = vectors.cases('rampart');
      expect(cases, hasLength(12));
      expect((cases.first['out']! as Map)['combatant'], isNull);
      final worn = (cases.last['out']! as Map)['combatant']! as List;
      final whole = (cases[10]['out']! as Map)['combatant']! as List;
      expect(worn[2]! as int, lessThan(whole[2]! as int));
    });

    test('count the worksites of every headquarters', () {
      expect(vectors.valuesOf('worksites', 'hq'), hasLength(11));
    });
  });
}

import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/vectors/domain/tech_cases.dart';
import '../../../../tool/vectors/domain/tech_vectors.dart';
import 'vector_reader.dart';

void main() {
  final vectors = VectorReader(TechVectors.file);
  final branches = {for (final b in TechBranch.values) b.name};

  group('TechVectors', () {
    test('walk every state of a branch: 6 levels, 2 choices of 2 options', () {
      expect(TechCases.states, hasLength(14));
      expect({for (final s in TechCases.states) '$s'}, hasLength(14));
      expect({for (final s in TechCases.states) s.$1}, {0, 1, 2, 3, 4, 5});
    });

    test('cost every branch, dearer with each branch opened', () {
      expect(vectors.valuesOf('unlockCost', 'branch'), branches);
      expect(vectors.valuesOf('unlockCost', 'percent').length, greaterThan(1));
      expect(vectors.valuesOf('researchCost', 'branch'), branches);
      for (final c in vectors.cases('researchCost')) {
        final int level = c['level']! as int;
        expect(c['out'], level < 1 || level > 5 ? isEmpty : isNotEmpty);
      }
    });

    test('tell the tiers, perks and options of every state', () {
      final cases = vectors.cases('branchState');
      expect(cases, hasLength(3 * 2 * 14));
      final outs = [for (final c in cases) c['out']! as Map];
      expect({for (final o in outs) o['tiers']}.length, greaterThan(2));
      expect(outs.where((o) => (o['perks']! as List).isNotEmpty), isNotEmpty);
      expect(
        {for (final o in outs) ...(o['options']! as List)},
        containsAll([null, 'a', 'b']),
      );
    });

    test('give every effect of every research, whole and halved', () {
      final cases = vectors.cases('effects');
      expect(cases, hasLength(TechCases.researches.length * 2));
      for (final String key in (cases.first['out']! as Map).keys.cast()) {
        expect(
          {for (final c in cases) '${(c['out']! as Map)[key]}'}.length,
          greaterThan(1),
          reason: 'no research changes $key',
        );
      }
      final whole = cases[cases.length - 2], halved = cases.last;
      expect(halved['tech'], whole['tech']);
      expect(halved['out'], isNot(whole['out']));
    });
  });
}

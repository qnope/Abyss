import 'package:abyss/domain/map/map_layout.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/vectors/domain/map_rule_vectors.dart';
import 'vector_reader.dart';

void main() {
  final vectors = VectorReader(MapRuleVectors.file);

  group('MapRuleVectors', () {
    test('size the map for every number of players', () {
      expect(vectors.cases('layout'), hasLength(MapLayout.maxPlayers));
      expect(
        {for (final Map<Object?, Object?> o in vectors.outs('layout').cast()) o['size']},
        {20, 26, 32},
      );
    });

    test('give the family of a lair from its seed and cell, level by level', () {
      final families = [
        for (final c in vectors.cases('lairFamily'))
          (c['level'], (c['out']! as List).toSet()),
      ];
      expect(families.where((f) => f.$1 == 1 && f.$2.contains('colossus')), isEmpty);
      expect(families.where((f) => f.$1 == 3 && f.$2.contains('colossus')), isNotEmpty);
      expect({for (final f in families) ...f.$2}, hasLength(4));
      // A seed past 2^31 is masked, not truncated.
      expect(vectors.valuesOf('lairFamily', 'seed'), contains(2147483649));
    });

    test('build a lair of each difficulty', () {
      expect(vectors.valuesOf('lair', 'difficulty'), {
        for (final d in MonsterDifficulty.values) d.name,
      });
      expect({for (final o in vectors.outs('lair')) '$o'}.length, greaterThan(20));
    });

    test('place 1 to 11 starting bases on the three sizes', () {
      expect(vectors.valuesOf('startingBases', 'size'), {20, 26, 32});
      for (final c in vectors.cases('startingBases')) {
        final List<Object?> bases = c['out']! as List<Object?>;
        expect(bases, hasLength(c['count']! as int));
        expect(bases.first, c['first']);
        expect({for (final b in bases) '$b'}, hasLength(bases.length));
      }
      expect(
        {for (final c in vectors.cases('startingBases')) '${c['out']}'}.length,
        greaterThan(30),
      );
    });

    test('reveal a square clipped by the edges of the map', () {
      var clipped = 0;
      for (final c in vectors.cases('reveal')) {
        final int side = c['side']! as int;
        final int count = (c['out']! as List).length;
        expect(count, lessThanOrEqualTo(side * side));
        if (count < side * side) clipped++;
      }
      expect(clipped, inExclusiveRange(0, vectors.cases('reveal').length));
    });

    test('name the posts of each type and place the volcano', () {
      expect(vectors.valuesOf('posts', 'type'), {
        for (final type in TransitionBaseType.values) type.name,
      });
      final codes = [
        for (final Map<Object?, Object?> o in vectors.outs('posts').cast())
          (o['codes']! as List).length,
      ];
      expect(codes.toSet().length, greaterThan(1));
      for (final List<Object?> cells in vectors.outs('volcano').cast()) {
        expect(cells, hasLength(4));
      }
    });
  });
}

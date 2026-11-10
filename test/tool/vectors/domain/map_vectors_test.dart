import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/vectors/domain/map_vectors.dart';
import '../../../../tool/vectors/domain/map_writer.dart';
import 'vector_reader.dart';

void main() {
  final vectors = VectorReader(MapVectors.file);
  final worlds = vectors.cases('world');
  final List<Map<String, Object?>> maps = [
    for (final c in worlds)
      ...(c['out']! as Map<String, Object?>).values.cast<Map<String, Object?>>(),
    ...vectors.outs('level').cast<Map<String, Object?>>(),
  ];
  final List<List<Object?>> cells = [
    for (final map in maps) ...(map['cells']! as List<Object?>).cast(),
  ];

  group('MapVectors', () {
    test('generate the three levels of every world, of the three sizes', () {
      for (final c in worlds) {
        final levels = c['out']! as Map<String, Object?>;
        expect(levels.keys, ['1', '2', '3']);
        expect((levels['1']! as Map)['bases'], hasLength(c['players']! as int));
      }
      expect({for (final map in maps) map['width']}, {20, 26, 32});
      expect(vectors.valuesOf('world', 'players'), containsAll([1, 2, 6, 11]));
    });

    test('write every cell that holds anything, in the order of the grid', () {
      for (final map in maps) {
        final int size = (map['width']! as int) * (map['height']! as int);
        var last = -1;
        for (final List<Object?> cell in (map['cells']! as List).cast()) {
          expect(cell[0]! as int, inExclusiveRange(last, size));
          expect(cell.length, inInclusiveRange(2, 5));
          expect(cell.last, isNotNull);
          last = cell[0]! as int;
        }
      }
    });

    test('hold every content, lair difficulty and family', () {
      // A wreck is sunk by an event, never by the generator.
      expect({for (final cell in cells) cell[1]}, {
        for (final content in CellContentType.values)
          if (content != CellContentType.wreck) content.name,
      });
      final lairs = [
        for (final cell in cells)
          if (cell.length > 2 && cell[2] != null) cell[2]! as List<Object?>,
      ];
      expect({for (final lair in lairs) lair[0]}, {
        for (final d in MonsterDifficulty.values) d.name,
      });
      expect({for (final lair in lairs) lair[1]}, {
        for (final f in MonsterFamily.values)
          if (f != MonsterFamily.kraken) f.name,
      });
    });

    test('keep what a cell held before its content changed', () {
      final stale = cells.where(
        (cell) => cell.length > 2 && cell[2] != null && cell[1] != 'monsterLair',
      );
      expect(stale, isNotEmpty);
      expect({for (final cell in stale) cell[1]}, contains('empty'));
    });

    test('write a cell back as it was generated', () {
      final result = MapGenerator.generate(seed: 42, level: 2);
      final written = MapWriter.write(result);
      final List<Object?> listed = written['cells']! as List<Object?>;
      final bare = result.map.cells.where(
        (cell) => MapWriter.cell(cell).join() == 'CellContentType.empty',
      );
      expect(listed.length + bare.length, result.map.cells.length);
      expect(written['seed'], result.map.seed);
    });

    test('keep the passages a level is asked for', () {
      final levels = vectors.cases('level');
      expect(vectors.valuesOf('level', 'level'), {1, 2, 3});
      expect(vectors.valuesOf('level', 'players'), {1, 5});
      final asked = levels.where((c) => (c['passages']! as List).isNotEmpty);
      expect(asked, isNotEmpty);
      for (final c in asked.where((c) => c['level'] != 1)) {
        final names = {
          for (final List<Object?> cell
              in ((c['out']! as Map)['cells']! as List).cast())
            if (cell.length == 5) cell[4],
        };
        expect(names, isNotEmpty, reason: 'seed ${c['seed']}');
      }
      final free = levels.where((c) => (c['passages']! as List).isEmpty);
      expect(
        {for (final c in free) '${c['out']}'}.intersection({
          for (final c in asked) '${c['out']}',
        }),
        isEmpty,
      );
    });
  });
}

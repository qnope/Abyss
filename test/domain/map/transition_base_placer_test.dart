import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base_placer.dart';
import 'package:abyss/domain/map/transition_base_type.dart';

void main() {
  const width = 20, height = 20, baseX = 10, baseY = 10;

  List<MapCell> makeCells() => List.generate(
        width * height,
        (_) => MapCell(terrain: TerrainType.plain),
      );

  int chebyshev(int x1, int y1, int x2, int y2) =>
      max((x1 - x2).abs(), (y1 - y2).abs());

  group('TransitionBasePlacer level 1', () {
    test('places 4 failles', () {
      for (var seed = 0; seed < 20; seed++) {
        final cells = makeCells();
        TransitionBasePlacer.place(
          cells: cells, width: width, height: height,
          baseX: baseX, baseY: baseY, level: 1,
          random: Random(seed),
        );
        final bases = cells.where(
          (c) => c.content == CellContentType.transitionBase,
        ).toList();
        expect(bases.length, 4, reason: 'seed=$seed');
        for (final b in bases) {
          expect(b.transitionBase!.type, TransitionBaseType.faille);
        }
      }
    });

    test('failles use expected names', () {
      final cells = makeCells();
      TransitionBasePlacer.place(
        cells: cells, width: width, height: height,
        baseX: baseX, baseY: baseY, level: 1,
        random: Random(42),
      );
      final names = cells
          .where((c) => c.content == CellContentType.transitionBase)
          .map((c) => c.transitionBase!.name)
          .toSet();
      expect(names, containsAll([
        'Faille Alpha', 'Faille Beta',
        'Faille Gamma', 'Faille Delta',
      ]));
    });

    test('failles are far from center', () {
      final cells = makeCells();
      TransitionBasePlacer.place(
        cells: cells, width: width, height: height,
        baseX: baseX, baseY: baseY, level: 1,
        random: Random(42),
      );
      for (var i = 0; i < cells.length; i++) {
        if (cells[i].content != CellContentType.transitionBase) {
          continue;
        }
        final x = i % width, y = i ~/ width;
        expect(
          chebyshev(x, y, 10, 10),
          greaterThanOrEqualTo(8),
          reason: 'faille at ($x,$y) too close to center',
        );
      }
    });

    test('base cell never has a transition base', () {
      for (var seed = 0; seed < 20; seed++) {
        final cells = makeCells();
        TransitionBasePlacer.place(
          cells: cells, width: width, height: height,
          baseX: baseX, baseY: baseY, level: 1,
          random: Random(seed),
        );
        final base = cells[baseY * width + baseX];
        expect(
          base.content,
          isNot(CellContentType.transitionBase),
          reason: 'seed=$seed',
        );
      }
    });
  });

  group('TransitionBasePlacer level 2', () {
    test('places 3 cheminees', () {
      for (var seed = 0; seed < 20; seed++) {
        final cells = makeCells();
        TransitionBasePlacer.place(
          cells: cells, width: width, height: height,
          baseX: baseX, baseY: baseY, level: 2,
          random: Random(seed),
        );
        final bases = cells.where(
          (c) => c.content == CellContentType.transitionBase,
        ).toList();
        expect(bases.length, 3, reason: 'seed=$seed');
        for (final b in bases) {
          expect(b.transitionBase!.type, TransitionBaseType.cheminee);
        }
      }
    });

    test('cheminees use expected names', () {
      final cells = makeCells();
      TransitionBasePlacer.place(
        cells: cells, width: width, height: height,
        baseX: baseX, baseY: baseY, level: 2,
        random: Random(42),
      );
      final names = cells
          .where((c) => c.content == CellContentType.transitionBase)
          .map((c) => c.transitionBase!.name)
          .toSet();
      expect(names, containsAll([
        'Cheminee Primaire',
        'Cheminee Secondaire',
        'Cheminee Tertiaire',
      ]));
    });
  });

  group('TransitionBasePlacer level 3+', () {
    test('places nothing', () {
      for (final level in [3, 4, 5]) {
        final cells = makeCells();
        TransitionBasePlacer.place(
          cells: cells, width: width, height: height,
          baseX: baseX, baseY: baseY, level: level,
          random: Random(42),
        );
        final bases = cells.where(
          (c) => c.content == CellContentType.transitionBase,
        ).toList();
        expect(bases, isEmpty, reason: 'level=$level');
      }
    });
  });

  group('TransitionBasePlacer determinism', () {
    test('same seed produces same placement', () {
      final a = makeCells();
      TransitionBasePlacer.place(
        cells: a, width: width, height: height,
        baseX: baseX, baseY: baseY, level: 1,
        random: Random(77),
      );
      final b = makeCells();
      TransitionBasePlacer.place(
        cells: b, width: width, height: height,
        baseX: baseX, baseY: baseY, level: 1,
        random: Random(77),
      );
      for (var i = 0; i < a.length; i++) {
        expect(a[i].content, b[i].content, reason: 'idx=$i');
        expect(
          a[i].transitionBase?.name,
          b[i].transitionBase?.name,
          reason: 'idx=$i',
        );
      }
    });
  });
}

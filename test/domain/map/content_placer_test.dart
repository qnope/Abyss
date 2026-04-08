import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/content_placer.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/terrain_generator.dart';
import 'package:abyss/domain/map/terrain_type.dart';

void main() {
  const width = 20, height = 20, baseX = 10, baseY = 10;

  List<MapCell> generate(int seed) {
    final random = Random(seed);
    final cells = TerrainGenerator.generate(
      width: width, height: height,
      random: random, baseX: baseX, baseY: baseY,
    );
    ContentPlacer.place(
      cells: cells, width: width, height: height,
      baseX: baseX, baseY: baseY, random: random,
    );
    return cells;
  }

  void expectLairUnitCountInRange(MapCell cell, {required int seed}) {
    expect(cell.lair, isNotNull, reason: 'seed=$seed');
    final lair = cell.lair!;
    final count = lair.unitCount;
    switch (lair.difficulty) {
      case MonsterDifficulty.easy:
        expect(count, inInclusiveRange(20, 50), reason: 'seed=$seed');
      case MonsterDifficulty.medium:
        expect(count, inInclusiveRange(60, 100), reason: 'seed=$seed');
      case MonsterDifficulty.hard:
        expect(count, inInclusiveRange(120, 200), reason: 'seed=$seed');
    }
  }

  group('ContentPlacer', () {
    test('base zone cells have empty content', () {
      final cells = generate(42);
      for (var dy = -2; dy <= 2; dy++) {
        for (var dx = -2; dx <= 2; dx++) {
          final x = baseX + dx, y = baseY + dy;
          if (x < 0 || x >= width || y < 0 || y >= height) continue;
          expect(
            cells[y * width + x].content,
            CellContentType.empty,
            reason: 'Base zone cell ($x,$y) should be empty',
          );
        }
      }
    });

    test('monster lair count is between 5 and 10', () {
      for (var seed = 0; seed < 20; seed++) {
        final cells = generate(seed);
        final count = cells
            .where((c) => c.content == CellContentType.monsterLair)
            .length;
        expect(count, greaterThanOrEqualTo(5), reason: 'seed=$seed');
        expect(count, lessThanOrEqualTo(10), reason: 'seed=$seed');
      }
    });

    test('each placed lair has a valid unit count', () {
      for (var seed = 0; seed < 20; seed++) {
        final cells = generate(seed);
        final lairs = cells
            .where((c) => c.content == CellContentType.monsterLair)
            .toList();
        expect(lairs, isNotEmpty, reason: 'seed=$seed');
        for (final cell in lairs) {
          expectLairUnitCountInRange(cell, seed: seed);
        }
      }
    });

    test('forced placement still yields a valid MonsterLair', () {
      // Use a small map so the main roll loop almost never places the
      // 5 required lairs and _adjustMonsterCount has to forcibly
      // promote empty cells to lairs via _placeMonster.
      const forcedWidth = 8, forcedHeight = 8;
      const forcedBaseX = 4, forcedBaseY = 4;
      var sawForced = false;
      for (var seed = 0; seed < 30; seed++) {
        final random = Random(seed);
        final cells = List<MapCell>.generate(
          forcedWidth * forcedHeight,
          (_) => MapCell(terrain: TerrainType.plain),
        );
        ContentPlacer.place(
          cells: cells,
          width: forcedWidth,
          height: forcedHeight,
          baseX: forcedBaseX,
          baseY: forcedBaseY,
          random: random,
        );
        final lairs = cells
            .where((c) => c.content == CellContentType.monsterLair)
            .toList();
        // At least 5 monsters should always exist when enough empty
        // cells are available to force-promote.
        expect(lairs.length, greaterThanOrEqualTo(5), reason: 'seed=$seed');
        for (final cell in lairs) {
          expectLairUnitCountInRange(cell, seed: seed);
        }
        // Detect whether the forced branch was used: if the natural
        // roll alone would rarely reach 5 on this tiny map, most seeds
        // should trigger it.
        final naturalMax = (forcedWidth * forcedHeight) ~/ 10;
        if (lairs.length > naturalMax) sawForced = true;
      }
      expect(
        sawForced,
        isTrue,
        reason: 'expected at least one seed to exercise forced placement',
      );
    });

    test('same seed produces same content', () {
      final a = generate(99);
      final b = generate(99);
      expect(
        a.map((c) => c.content).toList(),
        equals(b.map((c) => c.content).toList()),
      );
      expect(
        a.map((c) => c.lair?.difficulty).toList(),
        equals(b.map((c) => c.lair?.difficulty).toList()),
      );
      expect(
        a.map((c) => c.lair?.unitCount).toList(),
        equals(b.map((c) => c.lair?.unitCount).toList()),
      );
    });
  });
}

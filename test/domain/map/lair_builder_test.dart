import 'dart:math';

import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/lair_builder.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the family of a cell depends only on the seed and the cell', () {
    expect(LairBuilder.familyFor(7, 42, 2), LairBuilder.familyFor(7, 42, 2));
    final families = {
      for (int cell = 0; cell < 60; cell++) LairBuilder.familyFor(7, cell, 2),
    };
    expect(families, MonsterFamily.values.toSet());
  });

  test('level 1 lairs are never colossi', () {
    for (int cell = 0; cell < 200; cell++) {
      expect(LairBuilder.familyFor(3, cell, 1), isNot(MonsterFamily.colossus));
    }
  });

  test('picking a family does not consume the map dice', () {
    final a = Random(5);
    final b = Random(5);
    LairBuilder.build(
      difficulty: MonsterDifficulty.easy,
      random: a,
      familySeed: 1,
      cellIndex: 3,
    );
    LairBuilder.build(
      difficulty: MonsterDifficulty.easy,
      random: b,
      familySeed: 99,
      cellIndex: 80,
    );
    expect(a.nextInt(1000), b.nextInt(1000));
  });

  test('every lair of a new map has a family', () {
    final map = MapGenerator.generate(seed: 11).map;
    final lairs =
        map.cells
            .where((c) => c.content == CellContentType.monsterLair)
            .toList();
    expect(lairs, isNotEmpty);
    expect(lairs.every((c) => c.lair!.family != null), isTrue);
  });
}

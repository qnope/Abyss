import 'dart:math';
import 'cell_content_type.dart';
import 'map_cell.dart';
import 'monster_difficulty.dart';
import 'monster_lair.dart';

class ContentPlacer {
  static void place({
    required List<MapCell> cells,
    required int width,
    required int height,
    required int baseX,
    required int baseY,
    required Random random,
  }) {
    final eligible = _buildEligibleIndices(
      cells, width, height, baseX, baseY,
    );
    eligible.shuffle(random);

    var monsterCount = 0;
    final monsterIndices = <int>[];

    for (final i in eligible) {
      final roll = random.nextDouble();
      if (roll < 0.60) continue;
      final x = i % width, y = i ~/ width;
      if (roll < 0.80) {
        _placeResource(cells, i);
      } else if (roll < 0.90) {
        cells[i] = cells[i].copyWith(content: CellContentType.ruins);
      } else {
        _placeMonster(cells, i, x, y, baseX, baseY, random);
        monsterCount++;
        monsterIndices.add(i);
      }
    }

    _adjustMonsterCount(
      cells, eligible, monsterIndices, monsterCount,
      width, baseX, baseY, random,
    );
  }

  static List<int> _buildEligibleIndices(
    List<MapCell> cells,
    int width, int height,
    int baseX, int baseY,
  ) {
    final result = <int>[];
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final dist = max((x - baseX).abs(), (y - baseY).abs());
        if (dist <= 2) continue;
        result.add(y * width + x);
      }
    }
    return result;
  }

  static void _placeResource(List<MapCell> cells, int i) {
    cells[i] = cells[i].copyWith(
      content: CellContentType.resourceBonus,
    );
  }

  static void _placeMonster(
    List<MapCell> cells, int i,
    int x, int y, int baseX, int baseY,
    Random random,
  ) {
    final dist = max((x - baseX).abs(), (y - baseY).abs());
    final farFromBase = dist > 7;
    final roll = random.nextDouble();
    final MonsterDifficulty difficulty;
    if (farFromBase) {
      if (roll < 0.15) {
        difficulty = MonsterDifficulty.easy;
      } else if (roll < 0.50) {
        difficulty = MonsterDifficulty.medium;
      } else {
        difficulty = MonsterDifficulty.hard;
      }
    } else {
      if (roll < 0.50) {
        difficulty = MonsterDifficulty.easy;
      } else if (roll < 0.85) {
        difficulty = MonsterDifficulty.medium;
      } else {
        difficulty = MonsterDifficulty.hard;
      }
    }
    final unitCount = _rollUnitCount(difficulty, random);
    cells[i] = cells[i].copyWith(
      content: CellContentType.monsterLair,
      lair: MonsterLair(difficulty: difficulty, unitCount: unitCount),
    );
  }

  static int _rollUnitCount(
    MonsterDifficulty difficulty,
    Random random,
  ) {
    return switch (difficulty) {
      MonsterDifficulty.easy => 20 + random.nextInt(31),
      MonsterDifficulty.medium => 60 + random.nextInt(41),
      MonsterDifficulty.hard => 120 + random.nextInt(81),
    };
  }

  static void _adjustMonsterCount(
    List<MapCell> cells,
    List<int> eligible,
    List<int> monsterIndices,
    int monsterCount,
    int width, int baseX, int baseY,
    Random random,
  ) {
    while (monsterCount < 5) {
      final empty = eligible.where(
        (i) => cells[i].content == CellContentType.empty,
      ).toList();
      if (empty.isEmpty) break;
      final i = empty[random.nextInt(empty.length)];
      final x = i % width, y = i ~/ width;
      _placeMonster(cells, i, x, y, baseX, baseY, random);
      monsterCount++;
    }
    while (monsterCount > 10) {
      final i = monsterIndices.removeLast();
      cells[i] = cells[i].copyWith(
        content: CellContentType.empty,
      );
      monsterCount--;
    }
  }
}

import 'dart:math';
import 'cell_content_type.dart';
import 'map_cell.dart';
import 'lair_builder.dart';
import 'monster_difficulty.dart';

class ContentPlacer {
  // A roll in [0.60, 0.80) used to place a treasure and one in
  // [0.80, 0.90) ruins. Only the first third of each band still does, so
  // a seed keeps a subset of the treasures it used to place and replays
  // of older games still find them. Monster lairs keep [0.90, 1).
  static const _resourceFrom = 0.60;
  static const _ruinsFrom = 0.80;
  static const _monsterFrom = 0.90;
  static const _keptShare = 1 / 3;

  static CellContentType? _treasureFor(double roll) {
    bool keeps(double from, double to) =>
        roll >= from && roll < from + (to - from) * _keptShare;
    if (keeps(_resourceFrom, _ruinsFrom)) return CellContentType.resourceBonus;
    if (keeps(_ruinsFrom, _monsterFrom)) return CellContentType.ruins;
    return null;
  }

  static void place({
    required List<MapCell> cells,
    required int width,
    required int height,
    required int baseX,
    required int baseY,
    required Random random,
    Set<int> reservedIndices = const {},
    int familySeed = 0,
  }) {
    final eligible = _buildEligibleIndices(
      cells, width, height, baseX, baseY, reservedIndices,
    );
    eligible.shuffle(random);

    var monsterCount = 0;
    final monsterIndices = <int>[];

    for (final i in eligible) {
      final roll = random.nextDouble();
      if (roll < _monsterFrom) {
        final treasure = _treasureFor(roll);
        if (treasure != null) cells[i] = cells[i].copyWith(content: treasure);
      } else {
        final x = i % width, y = i ~/ width;
        _placeMonster(cells, i, x, y, baseX, baseY, random, familySeed);
        monsterCount++;
        monsterIndices.add(i);
      }
    }

    _adjustMonsterCount(
      cells, eligible, monsterIndices, monsterCount,
      width, baseX, baseY, random, familySeed,
    );
  }

  static List<int> _buildEligibleIndices(
    List<MapCell> cells,
    int width, int height,
    int baseX, int baseY,
    Set<int> reservedIndices,
  ) {
    final result = <int>[];
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final idx = y * width + x;
        final dist = max((x - baseX).abs(), (y - baseY).abs());
        if (dist <= 2) continue;
        if (reservedIndices.contains(idx)) continue;
        result.add(idx);
      }
    }
    return result;
  }

  static void _placeMonster(
    List<MapCell> cells, int i,
    int x, int y, int baseX, int baseY,
    Random random, int familySeed,
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
    cells[i] = cells[i].copyWith(
      content: CellContentType.monsterLair,
      lair: LairBuilder.build(
        difficulty: difficulty,
        random: random,
        familySeed: familySeed,
        cellIndex: i,
      ),
    );
  }

  static void _adjustMonsterCount(
    List<MapCell> cells,
    List<int> eligible,
    List<int> monsterIndices,
    int monsterCount,
    int width, int baseX, int baseY,
    Random random, int familySeed,
  ) {
    while (monsterCount < 5) {
      final empty = eligible.where(
        (i) => cells[i].content == CellContentType.empty,
      ).toList();
      if (empty.isEmpty) break;
      final i = empty[random.nextInt(empty.length)];
      final x = i % width, y = i ~/ width;
      _placeMonster(cells, i, x, y, baseX, baseY, random, familySeed);
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

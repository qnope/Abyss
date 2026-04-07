import 'package:hive/hive.dart';
import 'cell_content_type.dart';
import 'monster_difficulty.dart';
import 'terrain_type.dart';

part 'map_cell.g.dart';

@HiveType(typeId: 13)
class MapCell {
  @HiveField(0)
  final TerrainType terrain;

  @HiveField(1)
  final CellContentType content;

  @HiveField(2)
  final MonsterDifficulty? monsterDifficulty;

  @HiveField(3)
  final bool isRevealed;

  @HiveField(6)
  final bool isCollected;

  MapCell({
    required this.terrain,
    this.content = CellContentType.empty,
    this.monsterDifficulty,
    this.isRevealed = false,
    this.isCollected = false,
  });

  MapCell copyWith({
    TerrainType? terrain,
    CellContentType? content,
    MonsterDifficulty? monsterDifficulty,
    bool? isRevealed,
    bool? isCollected,
  }) {
    return MapCell(
      terrain: terrain ?? this.terrain,
      content: content ?? this.content,
      monsterDifficulty: monsterDifficulty ?? this.monsterDifficulty,
      isRevealed: isRevealed ?? this.isRevealed,
      isCollected: isCollected ?? this.isCollected,
    );
  }
}

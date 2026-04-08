import 'package:hive/hive.dart';
import 'cell_content_type.dart';
import 'monster_difficulty.dart';
import 'terrain_type.dart';

part 'map_cell.g.dart';

const Object _sentinel = Object();

@HiveType(typeId: 13)
class MapCell {
  @HiveField(0)
  final TerrainType terrain;

  @HiveField(1)
  final CellContentType content;

  @HiveField(2)
  final MonsterDifficulty? monsterDifficulty;

  @HiveField(3)
  final String? collectedBy;

  MapCell({
    required this.terrain,
    this.content = CellContentType.empty,
    this.monsterDifficulty,
    this.collectedBy,
  });

  bool get isCollected => collectedBy != null;

  MapCell copyWith({
    TerrainType? terrain,
    CellContentType? content,
    MonsterDifficulty? monsterDifficulty,
    Object? collectedBy = _sentinel,
  }) {
    return MapCell(
      terrain: terrain ?? this.terrain,
      content: content ?? this.content,
      monsterDifficulty: monsterDifficulty ?? this.monsterDifficulty,
      collectedBy: identical(collectedBy, _sentinel)
          ? this.collectedBy
          : collectedBy as String?,
    );
  }
}

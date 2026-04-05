import 'package:hive/hive.dart';
import 'cell_content_type.dart';
import 'monster_difficulty.dart';
import 'resource_type.dart';
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

  @HiveField(4)
  final ResourceType? bonusResourceType;

  @HiveField(5)
  final int? bonusAmount;

  MapCell({
    required this.terrain,
    this.content = CellContentType.empty,
    this.monsterDifficulty,
    this.isRevealed = false,
    this.bonusResourceType,
    this.bonusAmount,
  });

  MapCell copyWith({
    TerrainType? terrain,
    CellContentType? content,
    MonsterDifficulty? monsterDifficulty,
    bool? isRevealed,
    ResourceType? bonusResourceType,
    int? bonusAmount,
  }) {
    return MapCell(
      terrain: terrain ?? this.terrain,
      content: content ?? this.content,
      monsterDifficulty: monsterDifficulty ?? this.monsterDifficulty,
      isRevealed: isRevealed ?? this.isRevealed,
      bonusResourceType: bonusResourceType ?? this.bonusResourceType,
      bonusAmount: bonusAmount ?? this.bonusAmount,
    );
  }
}

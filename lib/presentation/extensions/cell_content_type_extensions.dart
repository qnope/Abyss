import '../../domain/cell_content_type.dart';
import '../../domain/monster_difficulty.dart';

extension CellContentTypeExtensions on CellContentType {
  String get label => switch (this) {
    CellContentType.empty => 'Vide',
    CellContentType.resourceBonus => 'Ressources',
    CellContentType.ruins => 'Ruines',
    CellContentType.monsterLair => 'Repaire',
  };

  String? get svgPath => switch (this) {
    CellContentType.empty => null,
    CellContentType.resourceBonus =>
      'assets/icons/map_content/resource_bonus.svg',
    CellContentType.ruins => 'assets/icons/map_content/ruins.svg',
    CellContentType.monsterLair => null,
  };
}

extension MonsterDifficultyExtensions on MonsterDifficulty {
  String get label => switch (this) {
    MonsterDifficulty.easy => 'Facile',
    MonsterDifficulty.medium => 'Moyen',
    MonsterDifficulty.hard => 'Difficile',
  };

  String get svgPath => switch (this) {
    MonsterDifficulty.easy =>
      'assets/icons/map_content/monster_easy.svg',
    MonsterDifficulty.medium =>
      'assets/icons/map_content/monster_medium.svg',
    MonsterDifficulty.hard =>
      'assets/icons/map_content/monster_hard.svg',
  };
}

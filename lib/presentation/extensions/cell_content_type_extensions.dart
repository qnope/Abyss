import '../../domain/event/random_event_type.dart';
import '../../domain/map/cell_content_type.dart';
import '../../domain/map/monster_difficulty.dart';
import '../l10n/app_localizations.dart';
import 'random_event_type_extensions.dart';

extension CellContentTypeExtensions on CellContentType {
  String label(AppLocalizations l10n) => switch (this) {
    CellContentType.empty => l10n.cellContentEmpty,
    CellContentType.resourceBonus => l10n.cellContentResourceBonus,
    CellContentType.ruins => l10n.cellContentRuins,
    CellContentType.monsterLair => l10n.cellContentMonsterLair,
    CellContentType.transitionBase => l10n.transitionBaseFailleName,
    CellContentType.passage => l10n.cellContentPassage,
    CellContentType.volcanicKernel => l10n.buildingVolcanicKernelName,
    CellContentType.wreck => RandomEventType.wreck.label(l10n),
  };

  String? get svgPath => switch (this) {
    CellContentType.empty => null,
    CellContentType.resourceBonus =>
      'assets/icons/map_content/resource_bonus.svg',
    CellContentType.ruins => 'assets/icons/map_content/ruins.svg',
    CellContentType.monsterLair => null,
    CellContentType.transitionBase => null,
    CellContentType.passage => null,
    CellContentType.volcanicKernel =>
      'assets/icons/terrain/volcanic_kernel.svg',
    CellContentType.wreck => RandomEventType.wreck.illustration,
  };
}

extension MonsterDifficultyExtensions on MonsterDifficulty {
  String label(AppLocalizations l10n) => switch (this) {
    MonsterDifficulty.easy => l10n.monsterDifficultyEasy,
    MonsterDifficulty.medium => l10n.monsterDifficultyMedium,
    MonsterDifficulty.hard => l10n.monsterDifficultyHard,
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

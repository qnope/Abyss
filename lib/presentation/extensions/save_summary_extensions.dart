import 'package:flutter/material.dart';

import '../../domain/game/save_outcome.dart';
import '../../domain/game/save_summary.dart';
import '../l10n/app_localizations.dart';
import '../theme/abyss_colors.dart';
import '../widgets/map/map_level_info.dart';
import 'difficulty_extensions.dart';

/// What a save card writes about a game, in French.
extension SaveSummaryLabels on SaveSummary {
  String get depthName => MapLevelInfo.nameOf(deepestLevel);

  /// Thumbnail of the deepest level reached.
  String get thumbnail => MapLevelInfo.saveThumbnailOf(deepestLevel);

  /// The difficulty of a game still played, or that it was won or lost.
  /// A game won then played on keeps its victory.
  String badgeLabel(AppLocalizations l10n) => switch (outcome) {
    SaveOutcome.inProgress => difficulty.displayName(l10n).toUpperCase(),
    SaveOutcome.freePlay || SaveOutcome.victory => '★ VICTOIRE',
    SaveOutcome.defeat => 'DÉFAITE',
  };

  Color get badgeColor => switch (outcome) {
    SaveOutcome.inProgress => difficulty.color,
    SaveOutcome.freePlay || SaveOutcome.victory => AbyssColors.energyYellow,
    SaveOutcome.defeat => AbyssColors.error,
  };

  /// « Tour 14 · Profondeurs · QG niv. 3 ». A finished game tells its
  /// difficulty instead, its badge telling how it ended.
  String metaLine(AppLocalizations l10n) => switch (outcome) {
    SaveOutcome.inProgress || SaveOutcome.freePlay =>
      'Tour $turn · $depthName · QG niv. $headquartersLevel',
    SaveOutcome.victory =>
      'Tour $turn · $depthName · ${difficulty.displayName(l10n)}',
    SaveOutcome.defeat =>
      'Tombée au tour $turn · $depthName · ${difficulty.displayName(l10n)}',
  };

  /// The last line of a finished game; a game in progress lists its
  /// resources there instead.
  String? get footnote => switch (outcome) {
    SaveOutcome.inProgress || SaveOutcome.freePlay => null,
    SaveOutcome.victory =>
      volcanicKernelCaptured ? 'Noyau volcanique conquis' : 'Victoire',
    SaveOutcome.defeat => 'Voir le bilan de la partie',
  };

  /// Which game a "continue" resumes: « Alice · Tour 14 · Normal ».
  String resumeLabel(AppLocalizations l10n) =>
      '$playerName · Tour $turn · ${difficulty.displayName(l10n)}';
}

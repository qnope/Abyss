import 'package:flutter/material.dart';
import '../../domain/game/difficulty.dart';
import '../l10n/app_localizations.dart';
import '../theme/abyss_colors.dart';

extension DifficultyInfo on Difficulty {
  String displayName(AppLocalizations l10n) => switch (this) {
    Difficulty.easy => l10n.difficultyEasyName,
    Difficulty.normal => l10n.difficultyNormalName,
    Difficulty.hard => l10n.difficultyHardName,
  };

  String description(AppLocalizations l10n) => switch (this) {
    Difficulty.easy => l10n.difficultyEasyDescription,
    Difficulty.normal => l10n.difficultyNormalDescription,
    Difficulty.hard => l10n.difficultyHardDescription,
  };

  Color get color => switch (this) {
    Difficulty.easy => AbyssColors.success,
    Difficulty.normal => AbyssColors.biolumCyan,
    Difficulty.hard => AbyssColors.error,
  };
}

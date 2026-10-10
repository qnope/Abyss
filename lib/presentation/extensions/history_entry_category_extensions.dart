import 'package:flutter/material.dart';
import '../../domain/history/history_entry_category.dart';
import '../l10n/app_localizations.dart';
import '../theme/abyss_colors.dart';

/// Display primitives (icon, background color, label) for a
/// [HistoryEntryCategory]. Kept in the presentation layer so the domain
/// model stays free of UI dependencies.
extension HistoryEntryCategoryDisplay on HistoryEntryCategory {
  /// Material icon associated with this category.
  IconData get icon => switch (this) {
    HistoryEntryCategory.combat => Icons.shield,
    HistoryEntryCategory.building => Icons.build,
    HistoryEntryCategory.research => Icons.science,
    HistoryEntryCategory.recruit => Icons.group_add,
    HistoryEntryCategory.explore => Icons.explore,
    HistoryEntryCategory.collect => Icons.inventory_2,
    HistoryEntryCategory.turnEnd => Icons.hourglass_bottom,
    HistoryEntryCategory.capture => Icons.flag,
    HistoryEntryCategory.descent => Icons.arrow_downward,
    HistoryEntryCategory.reinforcement => Icons.groups,
    HistoryEntryCategory.raid => Icons.warning_amber,
    HistoryEntryCategory.volcano => Icons.volcano,
    HistoryEntryCategory.event => Icons.auto_awesome,
  };

  /// Background / accent color for this category, sourced from the
  /// current [ThemeData]. We map each category to a theme-defined color
  /// role so that no raw ARGB literal ever lands in widget code.
  Color backgroundColor(ThemeData theme) {
    final scheme = theme.colorScheme;
    return switch (this) {
      HistoryEntryCategory.combat => scheme.error,
      HistoryEntryCategory.building => AbyssColors.coralPink,
      HistoryEntryCategory.research => scheme.secondary,
      HistoryEntryCategory.recruit => AbyssColors.biolumPink,
      HistoryEntryCategory.explore => scheme.primary,
      HistoryEntryCategory.collect => AbyssColors.algaeGreen,
      HistoryEntryCategory.turnEnd => scheme.tertiary,
      HistoryEntryCategory.capture => AbyssColors.energyYellow,
      HistoryEntryCategory.descent => AbyssColors.biolumPurple,
      HistoryEntryCategory.reinforcement => AbyssColors.biolumTeal,
      HistoryEntryCategory.raid => AbyssColors.warning,
      HistoryEntryCategory.volcano => AbyssColors.coralPink,
      HistoryEntryCategory.event => AbyssColors.biolumCyan,
    };
  }

  /// Human-readable label for this category.
  String label(AppLocalizations l10n) => switch (this) {
    HistoryEntryCategory.combat => l10n.historyCategoryCombat,
    HistoryEntryCategory.building => l10n.historyCategoryBuilding,
    HistoryEntryCategory.research => l10n.historyCategoryResearch,
    HistoryEntryCategory.recruit => l10n.historyCategoryRecruit,
    HistoryEntryCategory.explore => l10n.historyCategoryExplore,
    HistoryEntryCategory.collect => l10n.historyCategoryCollect,
    HistoryEntryCategory.turnEnd => l10n.historyCategoryTurnEnd,
    HistoryEntryCategory.capture => l10n.historyCategoryCapture,
    HistoryEntryCategory.descent => l10n.historyCategoryDescent,
    HistoryEntryCategory.reinforcement => l10n.historyCategoryReinforcement,
    HistoryEntryCategory.raid => l10n.historyCategoryRaid,
    HistoryEntryCategory.volcano => l10n.historyCategoryVolcano,
    HistoryEntryCategory.event => l10n.historyCategoryEvent,
  };
}

import 'package:flutter/material.dart';
import '../../domain/history/history_entry_category.dart';
import '../theme/abyss_colors.dart';

/// Display primitives (icon, background color, French label) for a
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
    };
  }

  /// Human-readable French label for this category.
  String get label => switch (this) {
    HistoryEntryCategory.combat => 'Combat',
    HistoryEntryCategory.building => 'Construction',
    HistoryEntryCategory.research => 'Recherche',
    HistoryEntryCategory.recruit => 'Recrutement',
    HistoryEntryCategory.explore => 'Exploration',
    HistoryEntryCategory.collect => 'Collecte',
    HistoryEntryCategory.turnEnd => 'Fin de tour',
    HistoryEntryCategory.capture => 'Capture',
    HistoryEntryCategory.descent => 'Descente',
    HistoryEntryCategory.reinforcement => 'Renfort',
  };
}

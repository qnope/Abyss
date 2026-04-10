import 'package:flutter/material.dart';
import '../../domain/history/history_entry.dart';
import '../theme/abyss_colors.dart';
import 'history_entry_category_extensions.dart';

/// Display primitives for a concrete [HistoryEntry]. Centralises the
/// sealed-type switch so widget code (see `HistoryEntryCard`) stays dumb
/// and purely layout-focused.
extension HistoryEntryDisplay on HistoryEntry {
  /// Accent color used to tint the card's leading icon / edge.
  ///
  /// Combat entries override the category color so wins glow green and
  /// losses glow red; every other category delegates to
  /// [HistoryEntryCategoryDisplay.backgroundColor].
  Color accentColor(ThemeData theme) => switch (this) {
    CombatEntry(:final victory) =>
      victory ? AbyssColors.success : theme.colorScheme.error,
    CaptureEntry() => AbyssColors.energyYellow,
    BuildingEntry() ||
    ResearchEntry() ||
    RecruitEntry() ||
    ExploreEntry() ||
    CollectEntry() ||
    TurnEndEntry() ||
    DescentEntry() ||
    ReinforcementEntry() => category.backgroundColor(theme),
  };

  /// Whether tapping this entry should open a detail view.
  ///
  /// Only combat entries currently carry enough data (the full
  /// [FightResult]) to be replayable, so only they are tappable.
  bool get isTappable => switch (this) {
    CombatEntry() || CaptureEntry() => true,
    BuildingEntry() ||
    ResearchEntry() ||
    RecruitEntry() ||
    ExploreEntry() ||
    CollectEntry() ||
    TurnEndEntry() ||
    DescentEntry() ||
    ReinforcementEntry() => false,
  };
}

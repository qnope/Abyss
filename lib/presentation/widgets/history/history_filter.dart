import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';

/// Filter options exposed in the history screen.
///
/// `combat`, `building` and `research` map directly to a single
/// [HistoryEntryCategory]. `other` groups the lower-volume categories
/// (recruit, explore, collect, turnEnd) into a single bucket.
enum HistoryFilter { all, combat, building, research, other }

extension HistoryFilterLabel on HistoryFilter {
  String get label => switch (this) {
    HistoryFilter.all => 'Tous',
    HistoryFilter.combat => 'Combats',
    HistoryFilter.building => 'Construction',
    HistoryFilter.research => 'Recherche',
    HistoryFilter.other => 'Autres',
  };
}

/// Returns [entries] filtered by [filter].
///
/// Pure function — no BuildContext, no side effects. Trivially testable.
List<HistoryEntry> applyHistoryFilter(
  List<HistoryEntry> entries,
  HistoryFilter filter,
) {
  return switch (filter) {
    HistoryFilter.all => entries,
    HistoryFilter.combat => entries
        .where((e) => e.category == HistoryEntryCategory.combat)
        .toList(),
    HistoryFilter.building => entries
        .where((e) => e.category == HistoryEntryCategory.building)
        .toList(),
    HistoryFilter.research => entries
        .where((e) => e.category == HistoryEntryCategory.research)
        .toList(),
    HistoryFilter.other => entries.where((e) {
      return e.category == HistoryEntryCategory.recruit ||
          e.category == HistoryEntryCategory.explore ||
          e.category == HistoryEntryCategory.collect ||
          e.category == HistoryEntryCategory.turnEnd ||
          e.category == HistoryEntryCategory.capture ||
          e.category == HistoryEntryCategory.descent ||
          e.category == HistoryEntryCategory.reinforcement;
    }).toList(),
  };
}

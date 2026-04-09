import 'package:abyss/domain/history/history_entry_category.dart';

/// Abstract base class for all history entries.
///
/// Each player action and end-of-turn event produces a concrete subclass
/// of [HistoryEntry]. The sealed hierarchy enables exhaustive `switch` on
/// concrete types in the presentation layer.
///
/// Note: Hive does not walk abstract sealed bases, so this class carries
/// no Hive annotations. Concrete subclasses define their own `@HiveType`
/// and `@HiveField` annotations.
sealed class HistoryEntry {
  final int turn;
  final HistoryEntryCategory category;
  final String title;
  final String? subtitle;

  const HistoryEntry({
    required this.turn,
    required this.category,
    required this.title,
    this.subtitle,
  });
}

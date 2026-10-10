part of '../history_entry.dart';

/// History entry recording how a random event played out: the player's
/// choice, or the prudent option when the turn ended without one.
///
/// The presentation layer titles it after its [type] and words the
/// choice.
@HiveType(typeId: 52)
class EventEntry extends HistoryEntry {
  @HiveField(0)
  @override
  final int turn;

  @HiveField(1)
  @override
  final HistoryEntryCategory category;

  /// Left empty: the presentation titles the entry in the player's
  /// language. Kept so the Hive layout keeps its field 2.
  @HiveField(2)
  final String title;

  /// Always `null`: the presentation words the player's choice.
  @HiveField(3)
  final String? subtitle;

  @HiveField(4)
  final RandomEventType type;

  /// Whether the event was accepted; always `true` for an event drawn
  /// without a choice.
  @HiveField(5)
  final bool accepted;

  /// Whether the prudent option applied because the player did not
  /// choose.
  @HiveField(6)
  final bool defaulted;

  EventEntry({
    required this.turn,
    required this.type,
    required this.accepted,
    required this.defaulted,
  }) : category = HistoryEntryCategory.event,
       title = '',
       subtitle = null;
}

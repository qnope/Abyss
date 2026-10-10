part of '../history_entry.dart';

/// History entry recording how a random event played out: the player's
/// choice, or the prudent option when the turn ended without one.
///
/// The presentation layer titles it after its [type].
@HiveType(typeId: 52)
class EventEntry extends HistoryEntry {
  @HiveField(0)
  @override
  final int turn;

  @HiveField(1)
  @override
  final HistoryEntryCategory category;

  @HiveField(2)
  @override
  final String title;

  @HiveField(3)
  @override
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
       title = 'Événement',
       subtitle = _eventChoiceOf(type, accepted, defaulted);
}

String? _eventChoiceOf(RandomEventType type, bool accepted, bool defaulted) {
  if (!type.hasChoice) return null;
  if (defaulted) return 'Option prudente, sans choix';
  return accepted ? 'Accepté' : 'Refusé';
}

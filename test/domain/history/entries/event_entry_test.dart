import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:flutter_test/flutter_test.dart';

EventEntry _entry({
  RandomEventType type = RandomEventType.caravan,
  bool accepted = false,
  bool defaulted = false,
}) => EventEntry(turn: 9, type: type, accepted: accepted, defaulted: defaulted);

void main() {
  test('is an event of its turn', () {
    final entry = _entry();
    expect(entry.turn, 9);
    expect(entry.category, HistoryEntryCategory.event);
    expect(entry.title, 'Événement');
  });

  test('says which choice the player made', () {
    expect(_entry(accepted: true).subtitle, 'Accepté');
    expect(_entry().subtitle, 'Refusé');
    expect(_entry(defaulted: true).subtitle, 'Option prudente, sans choix');
  });

  test('an event without a choice says nothing about it', () {
    expect(
      _entry(type: RandomEventType.storm, accepted: true).subtitle,
      isNull,
    );
  });
}

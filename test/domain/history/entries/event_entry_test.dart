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
  });

  test('records which choice the player made', () {
    final entry = _entry(accepted: true);
    expect(entry.type, RandomEventType.caravan);
    expect(entry.accepted, isTrue);
    expect(entry.defaulted, isFalse);
    expect(_entry(defaulted: true).defaulted, isTrue);
  });

  test('leaves its wording to the presentation', () {
    expect(_entry(accepted: true).subtitle, isNull);
  });
}

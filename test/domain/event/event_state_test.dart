import 'package:abyss/domain/event/event_state.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a new state has nothing scheduled, pending or active', () {
    final state = EventState();
    expect(state.nextDrawTurn, isNull);
    expect(state.hasPending, isFalse);
    expect(state.lastDrawn, isNull);
    expect(state.active, isNull);
    expect(state.heating, isFalse);
    expect(state.eventsSeen, 0);
  });

  test('schedule sets the turn of the next draw', () {
    final state = EventState()..schedule(13);
    expect(state.nextDrawTurn, 13);
  });

  test('setPending waits for a choice and remembers the draw', () {
    final state = EventState()..setPending(RandomEventType.wreck, 7);
    expect(state.hasPending, isTrue);
    expect(state.pending, RandomEventType.wreck);
    expect(state.pendingTurn, 7);
    expect(state.lastDrawn, RandomEventType.wreck);
    expect(state.eventsSeen, 1);
  });

  test('recordDraw remembers a draw that waits for no choice', () {
    final state = EventState()..recordDraw(RandomEventType.storm);
    expect(state.hasPending, isFalse);
    expect(state.lastDrawn, RandomEventType.storm);
    expect(state.eventsSeen, 1);
  });

  test('clearPending forgets the choice but keeps the last draw', () {
    final state =
        EventState()
          ..setPending(RandomEventType.caravan, 7)
          ..clearPending();
    expect(state.hasPending, isFalse);
    expect(state.pending, isNull);
    expect(state.pendingTurn, isNull);
    expect(state.lastDrawn, RandomEventType.caravan);
  });

  test('an activated effect lasts through its last turn inclusive', () {
    final state =
        EventState()..activate(RandomEventType.warmCurrent, untilTurn: 9);
    expect(state.isActive(RandomEventType.warmCurrent, 7), isTrue);
    expect(state.isActive(RandomEventType.warmCurrent, 9), isTrue);
    expect(state.isActive(RandomEventType.warmCurrent, 10), isFalse);
    expect(state.isActive(RandomEventType.storm, 8), isFalse);
  });

  test('activate resets the heating of a previous cold current', () {
    final state =
        EventState()
          ..activate(RandomEventType.coldCurrent, untilTurn: 9)
          ..heating = true
          ..activate(RandomEventType.storm, untilTurn: 12);
    expect(state.heating, isFalse);
  });

  test('expireEffects keeps the effect up to its last turn', () {
    final state =
        EventState()
          ..activate(RandomEventType.coldCurrent, untilTurn: 9)
          ..heating = true
          ..expireEffects(9);
    expect(state.active, RandomEventType.coldCurrent);
    expect(state.heating, isTrue);
  });

  test('expireEffects clears the effect after its last turn', () {
    final state =
        EventState()
          ..activate(RandomEventType.coldCurrent, untilTurn: 9)
          ..heating = true
          ..expireEffects(10);
    expect(state.active, isNull);
    expect(state.activeUntilTurn, isNull);
    expect(state.heating, isFalse);
  });

  test('expireEffects without an active effect changes nothing', () {
    final state = EventState()..expireEffects(10);
    expect(state.active, isNull);
  });
}

import 'dart:math';

import 'package:abyss/domain/event/event_drawer.dart';
import 'package:abyss/domain/event/event_rules.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:flutter_test/flutter_test.dart';

const _seeds = 300;

Set<RandomEventType?> _picks({
  required int endedTurn,
  RandomEventType? lastDrawn,
  Set<RandomEventType> excluded = const {},
}) => {
  for (var seed = 0; seed < _seeds; seed++)
    EventDrawer.pick(
      random: Random(seed),
      endedTurn: endedTurn,
      lastDrawn: lastDrawn,
      excluded: excluded,
    ),
};

void main() {
  group('firstDrawTurn', () {
    test('a new game draws between turns 5 and 8, all reachable', () {
      final turns = {
        for (var seed = 0; seed < _seeds; seed++)
          EventDrawer.firstDrawTurn(1, Random(seed)),
      };
      expect(turns, {5, 6, 7, 8});
      expect(EventRules.firstDrawMin, 5);
      expect(EventRules.firstDrawMax, 8);
    });

    test('a legacy save draws 5 to 8 turns after loading', () {
      final turns = {
        for (var seed = 0; seed < _seeds; seed++)
          EventDrawer.firstDrawTurn(40, Random(seed)),
      };
      expect(turns, {45, 46, 47, 48});
    });
  });

  test('nextDrawTurn waits 5 to 8 turns, all reachable', () {
    final turns = {
      for (var seed = 0; seed < _seeds; seed++)
        EventDrawer.nextDrawTurn(12, Random(seed)),
    };
    expect(turns, {17, 18, 19, 20});
  });

  group('pick', () {
    test('every type can be drawn once predators are allowed', () {
      expect(_picks(endedTurn: 20), RandomEventType.values.toSet());
    });

    test('never draws the same event twice in a row', () {
      for (final last in RandomEventType.values) {
        final picks = _picks(endedTurn: 20, lastDrawn: last);
        expect(picks, isNot(contains(last)));
        expect(picks, hasLength(RandomEventType.values.length - 1));
      }
    });

    test('honours the exclusions', () {
      final excluded = {RandomEventType.caravan, RandomEventType.wreck};
      final picks = _picks(endedTurn: 20, excluded: excluded);
      expect(picks.intersection(excluded), isEmpty);
      expect(picks, hasLength(RandomEventType.values.length - 2));
    });

    test('no predators for an event before turn 10', () {
      final early = EventRules.predatorsFirstTurn - 2;
      expect(
        _picks(endedTurn: early),
        isNot(contains(RandomEventType.predators)),
      );
      expect(_picks(endedTurn: early + 1), contains(RandomEventType.predators));
    });

    test('the same seed gives the same event', () {
      for (var seed = 0; seed < 20; seed++) {
        RandomEventType? draw() => EventDrawer.pick(
          random: Random(seed),
          endedTurn: 15,
          lastDrawn: RandomEventType.storm,
          excluded: const {RandomEventType.wreck},
        );
        expect(draw(), draw());
      }
    });

    test('returns null when every type is excluded', () {
      final all = RandomEventType.values.toSet();
      expect(_picks(endedTurn: 20, excluded: all), {null});
    });

    test('returns null when only the last draw is left', () {
      final excluded =
          RandomEventType.values.toSet()..remove(RandomEventType.storm);
      expect(
        _picks(
          endedTurn: 20,
          lastDrawn: RandomEventType.storm,
          excluded: excluded,
        ),
        {null},
      );
    });
  });
}

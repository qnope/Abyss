import 'dart:math';

import 'package:abyss/domain/event/effects/survivors_effect.dart';
import 'package:abyss/domain/event/event_drawer.dart';
import 'package:abyss/domain/event/event_production.dart';
import 'package:abyss/domain/event/event_state.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/resource/resource_type.dart';

import '../vector_file.dart';

/// When the random events are drawn, which ones, and what the lasting
/// ones do to the production.
abstract final class EventVectors {
  static const List<int> seeds = <int>[0, 1, 2, 3, 42, 1000, 2147483646];

  static const List<Set<RandomEventType>> _excluded = <Set<RandomEventType>>[
    {},
    {RandomEventType.wreck},
    {RandomEventType.wreck, RandomEventType.caravan, RandomEventType.storm},
    {
      RandomEventType.warmCurrent, RandomEventType.wreck,
      RandomEventType.storm, RandomEventType.survivors,
      RandomEventType.caravan, RandomEventType.coldCurrent,
    },
  ];

  /// The lasting event, its last turn and whether the farms are heated.
  static const List<(RandomEventType?, int?, bool)> _states = [
    (null, null, false),
    (RandomEventType.warmCurrent, 10, false),
    (RandomEventType.coldCurrent, 10, false),
    (RandomEventType.coldCurrent, 10, true),
    (RandomEventType.storm, 10, false),
  ];

  static const Map<ResourceType, int> _production = <ResourceType, int>{
    ResourceType.algae: 333,
    ResourceType.coral: 95,
    ResourceType.ore: 1,
    ResourceType.energy: 77,
    ResourceType.pearl: 3,
  };

  static final VectorFile file = VectorFile('events', {
    'drawTurns': VectorSection(
      '[EventDrawer.firstDrawTurn(turn, Random(seed)), '
          'EventDrawer.nextDrawTurn(turn, Random(seed))], a new generator '
          'for each',
      () => [
        for (final int turn in const [0, 1, 4, 5, 6, 30, 100])
          for (final int seed in seeds)
            {
              'turn': turn,
              'seed': seed,
              'out': [
                EventDrawer.firstDrawTurn(turn, Random(seed)),
                EventDrawer.nextDrawTurn(turn, Random(seed)),
              ],
            },
      ],
    ),
    'pick': VectorSection(
      'EventDrawer.pick(random: Random(seed), endedTurn: endedTurn, '
          'lastDrawn: lastDrawn, excluded: excluded as a set); next is '
          'the following nextInt(1000) of the generator, to tell whether '
          'the pick rolled',
      () => [
        for (final int endedTurn in const [5, 8, 9, 30])
          for (final RandomEventType? last in const [
            null, RandomEventType.predators, RandomEventType.coldCurrent,
          ])
            for (final Set<RandomEventType> excluded in _excluded)
              for (final int seed in seeds.take(excluded.isEmpty ? 7 : 3))
                _pick(endedTurn, last, excluded, seed),
      ],
    ),
    'survivors': VectorSection(
      'SurvivorsEffect.countAt(turn)',
      () => [
        for (final int turn in const [0, 5, 19, 20, 39, 40, 99, 100, 101, 250])
          {'turn': turn, 'out': SurvivorsEffect.countAt(turn)},
      ],
    ),
    'production': VectorSection(
      'With state = EventState(active: active, activeUntilTurn: until, '
          'heating: heating): EventProduction.percentOf(state, turn, type) '
          'for each type, EventProduction.adjust(production, state, turn) '
          'on a copy of production, and EventProduction.heatingEnergy'
          '(state, turn)',
      () => [
        for (final (RandomEventType? active, int? until, bool heating)
            in _states)
          for (final int turn in const [9, 10, 11])
            {
              'active': active,
              'until': until,
              'heating': heating,
              'turn': turn,
              'production': _production,
              'out': _adjusted(
                EventState(
                  active: active,
                  activeUntilTurn: until,
                  heating: heating,
                ),
                turn,
              ),
            },
      ],
    ),
  });

  static Map<String, Object?> _pick(
    int endedTurn,
    RandomEventType? lastDrawn,
    Set<RandomEventType> excluded,
    int seed,
  ) {
    final random = Random(seed);
    return {
      'endedTurn': endedTurn,
      'lastDrawn': lastDrawn,
      'excluded': excluded,
      'seed': seed,
      'out': EventDrawer.pick(
        random: random,
        endedTurn: endedTurn,
        lastDrawn: lastDrawn,
        excluded: excluded,
      ),
      'next': random.nextInt(1000),
    };
  }

  static Map<String, Object?> _adjusted(EventState state, int turn) => {
    'percents': {
      for (final ResourceType type in ResourceType.values)
        type: EventProduction.percentOf(state, turn, type),
    },
    'adjusted': EventProduction.adjust({..._production}, state, turn),
    'heatingEnergy': EventProduction.heatingEnergy(state, turn),
  };
}

import 'dart:math';

import 'package:abyss/domain/action/attack_base_action.dart';
import 'package:abyss/domain/action/descend_action.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/action/fight_monster_action.dart';
import 'package:abyss/domain/action/research_tech_action.dart';
import 'package:abyss/domain/replay/action_encoder.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/script/action_codec.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

/// One action of each verb, as a scenario writes it.
const List<Map<String, Object?>> _scenarioActions = <Map<String, Object?>>[
  {'do': 'upgrade', 'building': 'algaeFarm'},
  {'do': 'unlock', 'branch': 'military'},
  {'do': 'research', 'branch': 'explorer'},
  {'do': 'research', 'branch': 'military', 'option': 'b'},
  {'do': 'recruit', 'unit': 'guardian', 'count': 4},
  {'do': 'explore', 'x': 3, 'y': 4},
  {'do': 'event', 'accept': true},
  {'do': 'event', 'accept': false},
  {
    'do': 'garrison',
    'units': {'domeBreaker': 4, 'guardian': 2},
  },
  {
    'do': 'withdraw',
    'units': {'guardian': 1},
  },
  {'do': 'collect', 'x': 3, 'y': 4, 'level': 2, 'seed': 11},
  {
    'do': 'fight',
    'x': 1,
    'y': 2,
    'units': {'harpoonist': 5},
    'seed': 12,
  },
  {
    'do': 'attackBase',
    'x': 1,
    'y': 2,
    'units': {'scout': 1},
    'seed': 13,
  },
  {
    'do': 'attackKernel',
    'x': 1,
    'y': 2,
    'level': 3,
    'units': {'abyssAdmiral': 2},
    'seed': 14,
  },
  {
    'do': 'attackPlayer',
    'target': 'faction-pirates',
    'units': {'harpoonist': 5},
    'seed': 16,
  },
  {
    'do': 'attackPost',
    'x': 3,
    'y': 4,
    'level': 2,
    'units': {'harpoonist': 5},
    'seed': 18,
  },
  {
    'do': 'announceAttack',
    'units': {'harpoonist': 5},
    'seed': 17,
  },
  {
    'do': 'descend',
    'x': 5,
    'y': 6,
    'units': {'guardian': 3},
    'seed': 15,
  },
  {
    'do': 'reinforce',
    'x': 5,
    'y': 6,
    'level': 2,
    'units': {'guardian': 3},
  },
];

void main() {
  group('ActionEncoder', () {
    for (final Map<String, Object?> json in _scenarioActions) {
      test('writes back a ${json['do']} as the scenario reads it', () {
        final action = ActionCodec.decode(json)(Random(1));

        expect(ActionEncoder.encode(action), json);
        expect(ActionEncoder.isExact(action), isTrue);
      });
    }

    test('keeps the seed of a replayed fight', () {
      final action =
          ActionCodec.decode(<String, Object?>{
                'do': 'fight',
                'x': 1,
                'y': 2,
                'units': {'harpoonist': 5},
                'seed': 7,
              })(Random(1))
              as FightMonsterAction;

      expect((action.random as SeededRandom).seed, 7);
    });

    test('names the human target, whose id changes between games', () {
      final action = AttackBaseAction(
        targetPlayerId: 'uuid-1',
        selectedUnits: <UnitType, int>{UnitType.guardian: 2},
        random: SeededRandom(3),
      );

      expect(
        ActionEncoder.encode(action, humanId: 'uuid-1')!['target'],
        'human',
      );
      expect(
        ActionEncoder.encode(action, humanId: 'uuid-2')!['target'],
        'uuid-1',
      );
    });

    test('leaves out units the player did not send', () {
      final action = DescendAction(
        transitionX: 1,
        transitionY: 1,
        fromLevel: 1,
        selectedUnits: <UnitType, int>{UnitType.scout: 0, UnitType.guardian: 2},
        random: SeededRandom(3),
      );

      expect(ActionEncoder.encode(action)!['units'], {'guardian': 2});
    });

    test('flags dice that no seed can replay', () {
      final action = FightMonsterAction(
        targetX: 1,
        targetY: 2,
        level: 1,
        selectedUnits: <UnitType, int>{UnitType.harpoonist: 1},
        random: Random(1),
      );

      expect(ActionEncoder.encode(action), isNot(contains('seed')));
      expect(ActionEncoder.isExact(action), isFalse);
    });

    test('writes option A of a research as no option at all', () {
      final action =
          ResearchTechAction(branch: TechBranch.resources, option: TechOption.a);

      expect(ActionEncoder.encode(action),
          {'do': 'research', 'branch': 'resources'});
    });

    test('does not write the end of a turn as a move', () {
      expect(ActionEncoder.encode(EndTurnAction()), isNull);
    });
  });

  group('SeededRandom', () {
    test('rolls the same dice as a generator of the same seed', () {
      final SeededRandom seeded = SeededRandom(99);
      final Random plain = Random(99);

      expect(
        [seeded.nextInt(100), seeded.nextDouble(), seeded.nextBool()],
        [plain.nextInt(100), plain.nextDouble(), plain.nextBool()],
      );
    });
  });
}

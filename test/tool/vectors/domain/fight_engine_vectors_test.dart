import 'dart:math';

import 'package:abyss/domain/fight/combat_role.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/vectors/domain/fight_engine_vectors.dart';
import '../../../../tool/vectors/vector_json.dart';
import 'vector_reader.dart';

void main() {
  final vectors = VectorReader(FightEngineVectors.file);
  final fights = vectors.cases('resolve');
  List<Map<String, Object?>> outs(String section) =>
      vectors.outs(section).cast<Map<String, Object?>>();

  group('FightEngineVectors', () {
    test('hold all a port needs: a case replays from what it writes', () {
      for (final c in fights) {
        final replayed = FightEngineVectors.resolve(
          VectorReader.side(c['players']),
          VectorReader.side(c['monsters']),
          Random(c['seed']! as int),
        );
        expect(VectorJson.plain(replayed), c['out'], reason: '${c['fight']}');
      }
    });

    test('see both sides win, in one turn and in many', () {
      final winners = [for (final o in outs('resolve')) o['winner']];
      expect(winners.where((w) => w == 'player').length, greaterThan(20));
      expect(winners.where((w) => w == 'monster').length, greaterThan(20));
      final turns = {for (final o in outs('resolve')) o['turnCount']! as int};
      expect(turns, containsAll([0, 1]));
      expect(turns.reduce(max), greaterThan(10));
    });

    test('field every role and every monster family', () {
      final sides = [
        for (final c in fights) ...[
          ...VectorReader.side(c['players']),
          ...VectorReader.side(c['monsters']),
        ],
      ];
      expect({for (final c in sides) c.role}, CombatRole.values.toSet());
      expect(
        {for (final c in sides) c.family},
        {null, ...MonsterFamily.values},
      );
      expect(sides.where((c) => c.isBoss), isNotEmpty);
    });

    test('leave wounded survivors and crits to tell the dice apart', () {
      var crits = 0, wounded = 0;
      for (final c in fights) {
        final out = c['out']! as Map<String, Object?>;
        for (final List<Object?> turn in (out['turns']! as List).cast()) {
          crits += turn[1]! as int;
        }
        final players = VectorReader.side(c['players']);
        final List<int> left = (out['playerHp']! as List).cast<int>();
        expect(left, hasLength(players.length));
        for (var i = 0; i < left.length; i++) {
          if (left[i] > 0 && left[i] < players[i].maxHp) wounded++;
        }
      }
      expect(crits, greaterThan(50));
      expect(wounded, greaterThan(50));
    });

    test('change with the seed', () {
      final bySeed = <Object?, Set<String>>{};
      for (final c in fights) {
        bySeed.putIfAbsent(c['fight'], () => {}).add('${c['out']}');
      }
      expect(bySeed.values.where((o) => o.length == 3).length, greaterThan(15));
    });

    test('never crit at 0, always at 1', () {
      for (final c in vectors.cases('critChance')) {
        final double chance = VectorReader.number(c['critChance']);
        for (final List<Object?> turn
            in ((c['out']! as Map)['turns']! as List).cast()) {
          if (chance == 0) expect(turn[1], 0);
          if (chance == 1) expect(turn[1], turn[0]);
        }
      }
    });

    test('play a second fight on the dice the first one left', () {
      for (final List<Object?> two in vectors.outs('twoFights').cast()) {
        expect(two, hasLength(2));
        expect(two[0], isNot(two[1]));
      }
    });
  });
}

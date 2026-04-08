import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/fight_engine.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/fight/fight_turn_summary.dart';

Combatant _c({
  required CombatSide side,
  required String key,
  required int maxHp,
  required int atk,
  int def = 0,
}) {
  return Combatant(
    side: side,
    typeKey: key,
    maxHp: maxHp,
    atk: atk,
    def: def,
  );
}

List<Combatant> _strongPlayers() => <Combatant>[
      _c(side: CombatSide.player, key: 'p1', maxHp: 100, atk: 50),
      _c(side: CombatSide.player, key: 'p2', maxHp: 100, atk: 50),
      _c(side: CombatSide.player, key: 'p3', maxHp: 100, atk: 50),
      _c(side: CombatSide.player, key: 'p4', maxHp: 100, atk: 50),
      _c(side: CombatSide.player, key: 'p5', maxHp: 100, atk: 50),
    ];

List<Combatant> _weakPlayers() => <Combatant>[
      _c(side: CombatSide.player, key: 'p1', maxHp: 5, atk: 1),
    ];

List<Combatant> _weakMonsters() => <Combatant>[
      _c(side: CombatSide.monster, key: 'm1', maxHp: 5, atk: 1),
    ];

List<Combatant> _strongMonsters() => <Combatant>[
      _c(side: CombatSide.monster, key: 'm1', maxHp: 100, atk: 50),
      _c(side: CombatSide.monster, key: 'm2', maxHp: 100, atk: 50),
      _c(side: CombatSide.monster, key: 'm3', maxHp: 100, atk: 50),
      _c(side: CombatSide.monster, key: 'm4', maxHp: 100, atk: 50),
      _c(side: CombatSide.monster, key: 'm5', maxHp: 100, atk: 50),
    ];

void main() {
  group('FightEngine.resolve', () {
    test('victory: strong players crush a weak monster', () {
      final FightEngine engine = FightEngine(random: Random(1));
      final List<Combatant> players = _strongPlayers();
      final List<Combatant> monsters = _weakMonsters();

      final FightResult result = engine.resolve(
        playerSide: players,
        monsterSide: monsters,
      );

      expect(result.winner, CombatSide.player);
      expect(result.turnCount, greaterThanOrEqualTo(1));
      expect(monsters.every((Combatant c) => !c.isAlive), isTrue);
      expect(players.any((Combatant c) => c.isAlive), isTrue);
      expect(result.turnSummaries.length, result.turnCount);
    });

    test('defeat: strong monsters crush a weak player', () {
      final FightEngine engine = FightEngine(random: Random(2));
      final List<Combatant> players = _weakPlayers();
      final List<Combatant> monsters = _strongMonsters();

      final FightResult result = engine.resolve(
        playerSide: players,
        monsterSide: monsters,
      );

      expect(result.winner, CombatSide.monster);
      expect(players.every((Combatant c) => !c.isAlive), isTrue);
    });

    test('determinism: same seed -> identical turn count and summaries', () {
      FightResult run() {
        final FightEngine engine = FightEngine(random: Random(777));
        return engine.resolve(
          playerSide: <Combatant>[
            _c(side: CombatSide.player, key: 'p1', maxHp: 30, atk: 10, def: 5),
            _c(side: CombatSide.player, key: 'p2', maxHp: 30, atk: 10, def: 5),
          ],
          monsterSide: <Combatant>[
            _c(side: CombatSide.monster, key: 'm1', maxHp: 30, atk: 8, def: 3),
            _c(side: CombatSide.monster, key: 'm2', maxHp: 30, atk: 8, def: 3),
          ],
        );
      }

      final FightResult a = run();
      final FightResult b = run();

      expect(a.turnCount, b.turnCount);
      expect(a.turnSummaries.length, b.turnSummaries.length);
      for (int i = 0; i < a.turnSummaries.length; i += 1) {
        final FightTurnSummary sa = a.turnSummaries[i];
        final FightTurnSummary sb = b.turnSummaries[i];
        expect(sa.turnNumber, sb.turnNumber);
        expect(sa.attacksPlayed, sb.attacksPlayed);
        expect(sa.critCount, sb.critCount);
        expect(sa.damageDealtByPlayer, sb.damageDealtByPlayer);
        expect(sa.damageDealtByMonster, sb.damageDealtByMonster);
        expect(sa.playerAliveAtEnd, sb.playerAliveAtEnd);
        expect(sa.monsterAliveAtEnd, sb.monsterAliveAtEnd);
        expect(sa.playerHpAtEnd, sb.playerHpAtEnd);
        expect(sa.monsterHpAtEnd, sb.monsterHpAtEnd);
      }
    });

    test('no infinite loops: 1v1 with 0 ATK on both sides still terminates',
        () {
      final FightEngine engine = FightEngine(
        random: Random(3),
        critChance: 0.0,
      );
      final List<Combatant> players = <Combatant>[
        _c(side: CombatSide.player, key: 'p1', maxHp: 3, atk: 0, def: 0),
      ];
      final List<Combatant> monsters = <Combatant>[
        _c(side: CombatSide.monster, key: 'm1', maxHp: 3, atk: 0, def: 0),
      ];

      final FightResult result = engine.resolve(
        playerSide: players,
        monsterSide: monsters,
      );

      expect(result.turnCount, greaterThan(0));
      expect(
        players.any((Combatant c) => !c.isAlive) ||
            monsters.any((Combatant c) => !c.isAlive),
        isTrue,
      );
    });

    test('per-turn summary: 1v1 ATK==1 with crit off -> dmg == attacks * 1',
        () {
      final FightEngine engine = FightEngine(
        random: Random(10),
        critChance: 0.0,
      );
      final List<Combatant> players = <Combatant>[
        _c(side: CombatSide.player, key: 'p1', maxHp: 10, atk: 1, def: 0),
      ];
      final List<Combatant> monsters = <Combatant>[
        _c(side: CombatSide.monster, key: 'm1', maxHp: 10, atk: 1, def: 0),
      ];

      final FightResult result = engine.resolve(
        playerSide: players,
        monsterSide: monsters,
      );

      for (final FightTurnSummary s in result.turnSummaries) {
        expect(
          s.damageDealtByPlayer + s.damageDealtByMonster,
          s.attacksPlayed * 1,
        );
      }
    });

    test('initial snapshot is a clone: mutating it does not affect playerSide',
        () {
      final FightEngine engine = FightEngine(random: Random(4));
      final List<Combatant> players = <Combatant>[
        _c(side: CombatSide.player, key: 'p1', maxHp: 20, atk: 10, def: 2),
      ];
      final List<Combatant> monsters = <Combatant>[
        _c(side: CombatSide.monster, key: 'm1', maxHp: 20, atk: 10, def: 2),
      ];

      final FightResult result = engine.resolve(
        playerSide: players,
        monsterSide: monsters,
      );

      final int originalLiveHp = players[0].currentHp;
      result.initialPlayerCombatants[0].currentHp = 0;
      expect(players[0].currentHp, originalLiveHp);
    });
  });
}

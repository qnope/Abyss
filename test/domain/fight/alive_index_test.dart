import 'package:flutter_test/flutter_test.dart';

import 'package:abyss/domain/fight/alive_index.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';

Combatant _unit(String key, {bool alive = true}) =>
    _of(CombatSide.player, key, alive: alive);

Combatant _monster(String key, {bool alive = true}) =>
    _of(CombatSide.monster, key, alive: alive);

Combatant _of(CombatSide side, String key, {required bool alive}) {
  final Combatant c =
      Combatant(side: side, typeKey: key, maxHp: 10, atk: 2, def: 1);
  if (!alive) c.applyDamage(999);
  return c;
}

void main() {
  group('AliveIndex', () {
    test('counts the alive and lists them in pool order', () {
      final Combatant a = _unit('scout');
      final Combatant c = _unit('scout');
      final Combatant e = _unit('scout');
      final AliveIndex index = AliveIndex(<Combatant>[
        a,
        _unit('scout', alive: false),
        c,
        _unit('scout', alive: false),
        e,
      ]);

      expect(index.alive, 3);
      expect(index.nthAlive(0), same(a));
      expect(index.nthAlive(1), same(c));
      expect(index.nthAlive(2), same(e));
      expect(index.pool.length, 5);
    });

    test('tracks the alive taunting units', () {
      final Combatant g1 = _unit('guardian');
      final Combatant g2 = _unit('guardian');
      final AliveIndex index = AliveIndex(<Combatant>[
        _unit('harpoonist'),
        g1,
        _unit('guardian', alive: false),
        _unit('scout'),
        g2,
      ]);

      expect(index.taunting, 2);
      expect(index.nthTaunting(0), same(g1));
      expect(index.nthTaunting(1), same(g2));
    });

    test('tracks the alive swarm fish', () {
      final Combatant s1 = _monster('swarmL1');
      final Combatant s2 = _monster('swarmL1');
      final AliveIndex index = AliveIndex(<Combatant>[
        s1,
        _monster('hunterL1'),
        _monster('swarmL1', alive: false),
        s2,
      ]);

      expect(index.swarm, 2);
      expect(index.taunting, 0);
      expect(index.nthSwarm(0), same(s1));
      expect(index.nthSwarm(1), same(s2));
    });

    test('bury removes a fallen combatant from every count', () {
      final Combatant g = _unit('guardian');
      final Combatant h = _unit('harpoonist');
      final AliveIndex index = AliveIndex(<Combatant>[_unit('scout'), g, h]);

      g.applyDamage(999);
      index.bury(g);

      expect(index.alive, 2);
      expect(index.taunting, 0);
      expect(index.nthAlive(1), same(h));

      index.bury(g);
      expect(index.alive, 2);
    });

    test('bury removes a fallen fish from the swarm', () {
      final Combatant s1 = _monster('swarmL1');
      final Combatant s2 = _monster('swarmL1');
      final AliveIndex index = AliveIndex(<Combatant>[s1, s2]);

      s1.applyDamage(999);
      index.bury(s1);

      expect(index.swarm, 1);
      expect(index.nthSwarm(0), same(s2));
    });

    test('nthAliveExcept skips an alive excluded combatant', () {
      final Combatant a = _unit('scout');
      final Combatant b = _unit('scout');
      final Combatant c = _unit('scout');
      final Combatant d = _unit('scout');
      final AliveIndex index = AliveIndex(<Combatant>[a, b, c, d]);

      expect(index.aliveExcept(b), 3);
      expect(index.nthAliveExcept(0, b), same(a));
      expect(index.nthAliveExcept(1, b), same(c));
      expect(index.nthAliveExcept(2, b), same(d));
      expect(index.nthAliveExcept(0, a), same(b));
    });

    test('nthAliveExcept does not shift around a dead one', () {
      final Combatant a = _unit('scout');
      final Combatant dead = _unit('scout', alive: false);
      final Combatant c = _unit('scout');
      final AliveIndex index = AliveIndex(<Combatant>[a, dead, c]);

      expect(index.aliveExcept(dead), 2);
      expect(index.nthAliveExcept(0, dead), same(a));
      expect(index.nthAliveExcept(1, dead), same(c));
    });

    test('nthSwarmExcept skips the excluded fish only while it stands', () {
      final Combatant s1 = _monster('swarmL1');
      final Combatant s2 = _monster('swarmL1');
      final Combatant s3 = _monster('swarmL1');
      final AliveIndex index =
          AliveIndex(<Combatant>[s1, _monster('hunterL1'), s2, s3]);

      expect(index.swarmExcept(s2), 2);
      expect(index.nthSwarmExcept(0, s2), same(s1));
      expect(index.nthSwarmExcept(1, s2), same(s3));

      s2.applyDamage(999);
      index.bury(s2);
      expect(index.swarmExcept(s2), 2);
      expect(index.nthSwarmExcept(1, s2), same(s3));
    });
  });
}

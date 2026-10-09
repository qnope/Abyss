import 'dart:collection';

import '../map/monster_family.dart';
import 'combat_role.dart';
import 'combatant.dart';
import 'fenwick_tree.dart';

/// The alive combatants of one side of a fight, indexed for random picks.
///
/// Built once per fight over [pool]; [bury] drops a fallen combatant so
/// counts and n-th lookups, in pool order, stay O(log n) on every attack
/// instead of filtering the whole side. Three sets are tracked: the
/// alive, the alive that taunt, and the alive fish of the swarm.
class AliveIndex {
  final List<Combatant> pool;
  final FenwickTree _alive;
  final FenwickTree _taunting;
  final FenwickTree _swarm;
  final HashMap<Combatant, int> _positions = HashMap<Combatant, int>.identity();

  AliveIndex(this.pool)
      : _alive = FenwickTree(pool.length),
        _taunting = FenwickTree(pool.length),
        _swarm = FenwickTree(pool.length) {
    for (int i = 0; i < pool.length; i++) {
      _positions[pool[i]] = i;
      if (pool[i].isAlive) _mark(pool[i], i, 1);
    }
  }

  int get alive => _alive.total;
  int get taunting => _taunting.total;
  int get swarm => _swarm.total;

  /// The [n]-th alive combatant, 0-based, in pool order.
  Combatant nthAlive(int n) => pool[_alive.positionOfNth(n)];
  Combatant nthTaunting(int n) => pool[_taunting.positionOfNth(n)];
  Combatant nthSwarm(int n) => pool[_swarm.positionOfNth(n)];

  /// Alive combatants other than [c]; [c] only counts while it stands.
  int aliveExcept(Combatant c) => _alive.total - _weight(_alive, c);
  int swarmExcept(Combatant c) => _swarm.total - _weight(_swarm, c);

  /// The [n]-th alive combatant skipping [c], in pool order.
  Combatant nthAliveExcept(int n, Combatant c) =>
      pool[_nthExcept(_alive, n, c)];
  Combatant nthSwarmExcept(int n, Combatant c) =>
      pool[_nthExcept(_swarm, n, c)];

  /// Drops [c], which has just died, from every set; a no-op when it is
  /// already out.
  void bury(Combatant c) {
    final int? position = _positions[c];
    if (position == null || _alive.at(position) == 0) return;
    _mark(c, position, -1);
  }

  void _mark(Combatant c, int position, int delta) {
    _alive.add(position, delta);
    if (c.role == CombatRole.taunt) _taunting.add(position, delta);
    if (c.family == MonsterFamily.swarm) _swarm.add(position, delta);
  }

  /// Count [tree] holds for [c]: `0` when it is out or not in [pool].
  int _weight(FenwickTree tree, Combatant c) {
    final int? position = _positions[c];
    return position == null ? 0 : tree.at(position);
  }

  /// Position of the [n]-th combatant counted by [tree] skipping [c]: the
  /// next one when [c] stands among the first [n] + 1.
  int _nthExcept(FenwickTree tree, int n, Combatant c) {
    final int? position = _positions[c];
    if (position == null || tree.at(position) == 0) {
      return tree.positionOfNth(n);
    }
    final int rank = tree.prefix(position);
    return tree.positionOfNth(rank <= n ? n + 1 : n);
  }
}

class_name AliveIndex
extends RefCounted
## lib/domain/fight/alive_index.dart: the alive combatants of one side of a
## fight, indexed for random picks.
##
## Built once per fight over `pool`; `bury` drops a fallen combatant so
## counts and n-th lookups, in pool order, stay O(log n) on every attack
## instead of filtering the whole side. Three sets are tracked: the alive,
## the alive that taunt, and the alive fish of the swarm.

const _TAUNT := CombatRole.Value.TAUNT
const _SWARM := MonsterFamily.Value.SWARM
## What `_positions` answers for a combatant that is not of the pool, where
## the Dart map answers null.
const _NOWHERE := -1

var pool: Array[Combatant]

var _alive: FenwickTree
var _taunting: FenwickTree
var _swarm: FenwickTree
## Position of each combatant of the pool, keyed by identity as the Dart
## `HashMap.identity`: Godot compares objects so.
var _positions: Dictionary[Combatant, int] = {}


## Indexes `pool_` in one pass: one count per position for each set, then a
## linear tree build instead of a point update per combatant.
func _init(pool_: Array[Combatant]) -> void:
	pool = pool_
	var size := pool.size()
	var alive_counts := PackedInt64Array()
	var taunting_counts := PackedInt64Array()
	var swarm_counts := PackedInt64Array()
	alive_counts.resize(size)
	taunting_counts.resize(size)
	swarm_counts.resize(size)
	for i: int in size:
		var c := pool[i]
		_positions[c] = i
		if not c.is_alive():
			continue
		alive_counts[i] = 1
		if c.role == _TAUNT:
			taunting_counts[i] = 1
		if c.family == _SWARM:
			swarm_counts[i] = 1
	_alive = FenwickTree.from_counts(alive_counts)
	_taunting = FenwickTree.from_counts(taunting_counts)
	_swarm = FenwickTree.from_counts(swarm_counts)


func alive() -> int:
	return _alive.total


func taunting() -> int:
	return _taunting.total


func swarm() -> int:
	return _swarm.total


## The `n`-th alive combatant, 0-based, in pool order.
func nth_alive(n: int) -> Combatant:
	return pool[_alive.position_of_nth(n)]


func nth_taunting(n: int) -> Combatant:
	return pool[_taunting.position_of_nth(n)]


func nth_swarm(n: int) -> Combatant:
	return pool[_swarm.position_of_nth(n)]


## Alive combatants other than `c`; `c` only counts while it stands.
func alive_except(c: Combatant) -> int:
	return _alive.total - _weight(_alive, c)


func swarm_except(c: Combatant) -> int:
	return _swarm.total - _weight(_swarm, c)


## The `n`-th alive combatant skipping `c`, in pool order.
func nth_alive_except(n: int, c: Combatant) -> Combatant:
	return pool[_nth_except(_alive, n, c)]


func nth_swarm_except(n: int, c: Combatant) -> Combatant:
	return pool[_nth_except(_swarm, n, c)]


## Drops `c`, which has just died, from every set; a no-op when it is
## already out.
func bury(c: Combatant) -> void:
	var position: int = _positions.get(c, _NOWHERE)
	if position == _NOWHERE or _alive.at(position) == 0:
		return
	_alive.add(position, -1)
	if c.role == _TAUNT:
		_taunting.add(position, -1)
	if c.family == _SWARM:
		_swarm.add(position, -1)


## Count `tree` holds for `c`: `0` when it is out or not in the pool.
func _weight(tree: FenwickTree, c: Combatant) -> int:
	var position: int = _positions.get(c, _NOWHERE)
	return 0 if position == _NOWHERE else tree.at(position)


## Position of the `n`-th combatant counted by `tree` skipping `c`: the next
## one when `c` stands among the first `n` + 1.
func _nth_except(tree: FenwickTree, n: int, c: Combatant) -> int:
	var position: int = _positions.get(c, _NOWHERE)
	if position == _NOWHERE or tree.at(position) == 0:
		return tree.position_of_nth(n)
	var rank := tree.prefix(position)
	return tree.position_of_nth(n + 1 if rank <= n else n)

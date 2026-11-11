class_name FactionBaseTargets
extends RefCounted
## lib/domain/faction/faction_base_targets.dart: the bases a faction knows
## and has a report on, the weakest first.

## Bases a faction sends a Scout to in one slot.
const SPIES_PER_SLOT := 2


## The bases of the fog of `turn`'s player that a scout has reported on (a
## fresh report, or the one a Scout brings back now), the weakest defence
## against `ours` first; the human first on a `grudge` slot. It spies at most
## SPIES_PER_SLOT bases a slot, the nearest first.
static func weakest_first(turn: ScriptTurn, ours: Array[Combatant], grudge := false) -> Array[BaseTarget]:
	var me := turn.player
	var seen := GridPosition.keys(me.revealed_cells_on_level(RaidBattle.BASE_LEVEL))
	var known: Array[Player] = []
	for p: Player in turn.game.players.values():
		if p.id != me.id and not p.has_fallen() and seen.has(Vector2i(p.base_x, p.base_y)):
			known.append(p)
	DartSort.sort(known, func(a: Player, b: Player) -> int:
		if grudge and is_human(turn, a) != is_human(turn, b):
			return -1 if is_human(turn, a) else 1
		return DartSort.compare_ints(_distance(me, a), _distance(me, b)))
	var targets: Array[BaseTarget] = []
	var spies := 0
	for p: Player in known:
		var intel: BaseIntel = me.intel().get(p.id)
		if intel == null or not intel.is_fresh(turn.number()):
			if spies >= SPIES_PER_SLOT or not AssaultMoves.spy_on(turn, p.id):
				continue
			spies += 1
			intel = me.intel().get(p.id)
		targets.append(BaseTarget.new(p, intel, ours))
	DartSort.sort(targets, func(a: BaseTarget, b: BaseTarget) -> int:
		if grudge and is_human(turn, a.player) != is_human(turn, b.player):
			return -1 if is_human(turn, a.player) else 1
		var by_strength := DartNum.compare_to(a.strength, b.strength)
		return by_strength if by_strength != 0 else _compare_ids(a.player.id, b.player.id))
	return targets


## Whether `p` is the human of `turn`'s game.
static func is_human(turn: ScriptTurn, p: Player) -> bool:
	return p.id == turn.game.human_player_id


static func _distance(a: Player, b: Player) -> int:
	return maxi(absi(a.base_x - b.base_x), absi(a.base_y - b.base_y))


## `a.compareTo(b)` between two ids: the ids are ASCII, whose order is the
## same by UTF-16 unit (Dart) and by code point (GDScript).
static func _compare_ids(a: String, b: String) -> int:
	return -1 if a < b else (1 if a > b else 0)

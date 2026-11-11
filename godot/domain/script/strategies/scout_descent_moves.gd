class_name ScoutDescentMoves
extends RefCounted
## lib/domain/script/strategies/scout_descent_moves.dart: scouts sent down
## ahead of the army, through every post the player holds, in the same turn,
## since a descent moves the units at once. The Dart extension on
## ScriptTurn: each function takes the turn first.


## Deepest level the scouts of the base reach this turn: one level down for
## each post held, from the base, whose passage building stands.
static func deepest_reachable(turn: ScriptTurn) -> int:
	var level := 1
	while level < 3 and _passage_open(turn, level):
		level += 1
	return level


## Scouts the base must send so that `wanted` stand on deepest_reachable,
## counting those already on the way there.
static func scouts_missing_below(turn: ScriptTurn, wanted: int) -> int:
	var bottom := deepest_reachable(turn)
	if bottom == 1 or _road_seen(turn, bottom):
		return 0
	return _missing(turn, bottom, wanted)


## Sends scouts down until `wanted` stand on deepest_reachable; the scouts
## already on the way go first, the base gives the rest.
static func send_scouts_down(turn: ScriptTurn, wanted: int) -> void:
	var bottom := deepest_reachable(turn)
	if bottom == 1:
		return
	var need := wanted - _scouts_on(turn, bottom)
	if need <= 0 or _road_seen(turn, bottom):
		return
	var from_home := clampi(_missing(turn, bottom, wanted), 0, _scouts_on(turn, 1))
	if from_home > 0:
		ExpeditionMoves.descend(turn, 1, {UnitType.Value.SCOUT: from_home})
	for level: int in range(2, bottom):
		var n := mini(_scouts_on(turn, level), need)
		ExpeditionMoves.descend(turn, level, {UnitType.Value.SCOUT: n})


## Scouts short of `wanted` on levels 2 to `bottom` together.
static func _missing(turn: ScriptTurn, bottom: int, wanted: int) -> int:
	var below := 0
	for level: int in range(2, bottom + 1):
		below += _scouts_on(turn, level)
	return wanted - below if wanted > below else 0


## Whether the fog of `level` shows what the road needs there: the Cheminée
## on level 2, the volcano on level 3.
static func _road_seen(turn: ScriptTurn, level: int) -> bool:
	if level == 2:
		return ExpeditionMoves.open_base(turn, 2) != null or ExpeditionMoves.own_base(turn, 2) != null
	return ExpeditionMoves.kernel_seen(turn)


## Whether the player holds the post of `level` and may go through it.
static func _passage_open(turn: ScriptTurn, level: int) -> bool:
	var via := ExpeditionMoves.own_base(turn, level)
	if via == null:
		return false
	var type := turn.game.levels[level].cell_at(via.x, via.y).transition_base.type
	var passage := (
		BuildingType.Value.DESCENT_MODULE if type == TransitionBaseType.Value.FAILLE
		else BuildingType.Value.PRESSURE_CAPSULE
	)
	return Building.level_in(turn.player.buildings, passage) > 0 and not turn.player.is_degraded(passage)


static func _scouts_on(turn: ScriptTurn, level: int) -> int:
	var scouts: Unit = turn.player.units_on_level(level).get(UnitType.Value.SCOUT)
	return 0 if scouts == null else scouts.count

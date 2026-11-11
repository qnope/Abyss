class_name PlanMoves
extends RefCounted
## lib/domain/script/variant/plan_moves.dart: plays the steps of a human
## plan, on its own map or on a new one. The Dart extension on ScriptTurn:
## each function takes the turn first.
##
## On a new map, a step that aims at a cell aims instead at the cell that
## plays the same part there: the open transition base of the level, the
## kernel, the player's own base to go down, the weakest lair, the frontier
## cell that reveals the most.


## Plays `step`; returns whether it succeeded, so a failed step can be tried
## again on a later turn.
static func play_step(turn: ScriptTurn, step: PlanStep, variant: ReplayVariant) -> bool:
	var moved := not variant.same_map and step.on_map()
	if moved and step.verb() == "explore":
		return _explore_one(turn, step.level())
	if moved and step.verb() == "collect":
		ExploreMoves.collect_revealed(turn, step.level())
		return true
	var target: GridPosition = _target_of(turn, step) if moved else null
	if moved and target == null:
		return _search_for(turn, step)
	var adapted: Variant = step.adapt(variant, _units_on(turn, step))
	if adapted == null:
		return false
	var json: Dictionary = adapted
	if target != null:
		json["x"] = target.x
		json["y"] = target.y
	var spec := ActionCodec.decode(json)
	if not spec.is_valid():
		return false
	var action: Action = spec.call(turn.random())
	return turn.perform(action).is_success


static func _units_on(turn: ScriptTurn, step: PlanStep) -> Dictionary[UnitType.Value, int]:
	var counts: Dictionary[UnitType.Value, int] = {}
	var on_level := turn.player.units_on_level(step.level())
	for type: UnitType.Value in on_level:
		counts[type] = on_level[type].count
	return counts


static func _target_of(turn: ScriptTurn, step: PlanStep) -> GridPosition:
	match step.verb():
		"attackBase":
			return ExpeditionMoves.open_base(turn, step.level())
		"attackKernel":
			return ExpeditionMoves.open_kernel(turn)
		"descend", "reinforce":
			return ExpeditionMoves.own_base(turn, step.level())
		"fight":
			return _weakest_lair(turn, step.level())
	return null


static func _weakest_lair(turn: ScriptTurn, level: int) -> GridPosition:
	var best: GridPosition = null
	var best_power := 1 << 30
	var lairs := ExploreMoves.revealed_where(turn, level, func(c: MapCell) -> bool:
		return c.content == CellContentType.Value.MONSTER_LAIR and not c.is_collected() and c.lair != null)
	for p: GridPosition in lairs:
		var lair := turn.game.levels[level].cell_at(p.x, p.y).lair
		var power := lair.total_count() * lair.level() * lair.level()
		if power < best_power:
			best = p
			best_power = power
	return best


## Explores the step's level with two scouts, recruiting them on the base
## level if needed, since the target it waits for is not revealed yet.
static func _search_for(turn: ScriptTurn, step: PlanStep) -> bool:
	if step.verb() == "descend" or step.verb() == "reinforce":
		return false
	var level := step.level()
	var scouts := _scouts(turn, level)
	if level == 1 and scouts < 2:
		turn.try_perform(RecruitUnitAction.new(UnitType.Value.SCOUT, 2 - scouts))
	_explore_one(turn, level)
	_explore_one(turn, level)
	return false


## Sends one scout of `level` where a careful player would: towards the
## edges while the way down is unknown, towards the kernel below.
static func _explore_one(turn: ScriptTurn, level: int) -> bool:
	var before := _scouts(turn, level)
	ExploreMoves.explore(turn, level, 1, func(p: GridPosition) -> float:
		var edge := maxi(absi(p.x - 10), absi(p.y - 10))
		match level:
			1:
				var known := ExpeditionMoves.own_base(turn, 1) != null or ExpeditionMoves.open_base(turn, 1) != null
				return 0.0 if known else 0.3 * edge
			2:
				return 0.5 * edge if ExpeditionMoves.open_base(turn, 2) == null else 0.0
		return -1.0 * edge if ExpeditionMoves.open_kernel(turn) == null else 0.0)
	return _scouts(turn, level) < before


static func _scouts(turn: ScriptTurn, level: int) -> int:
	var scouts: Unit = turn.player.units_on_level(level).get(UnitType.Value.SCOUT)
	return scouts.count if scouts != null else 0

class_name RecruitMoves
extends RefCounted
## lib/domain/script/strategies/recruit_moves.dart: recruiting by "mixes", a
## fixed ratio of unit types recruited together, such as one Gardien for two
## Harponneurs. The Dart extension on ScriptTurn: each function takes the
## turn first.
##
## A mix is a Dictionary of UnitType.Value to a count, typed or not: the
## mixes of the strategies are constants, whose inner maps GDScript leaves
## untyped. `enemy` and `allies` give fresh combatants, as for ArmyPlanner
## (`allies` not valid for none).

## Most mixes recruited in one go: beyond that a plan is never sane.
const MAX_BATCH := 150


static func barracks_level(turn: ScriptTurn) -> int:
	return Building.level_in(turn.player.buildings, BuildingType.Value.BARRACKS)


## Mixes the barracks can train this turn, from `candidates`.
static func usable_mixes(turn: ScriptTurn, candidates: Array[Dictionary]) -> Array[Dictionary]:
	var usable: Array[Dictionary] = []
	for mix: Dictionary in candidates:
		var trainable := true
		for t: UnitType.Value in mix:
			if not UnitCostCalculator.new().is_unlocked(t, barracks_level(turn)) or turn.player.recruited_unit_types.has(t):
				trainable = false
				break
		if trainable:
			usable.append(mix)
	return usable


## How many times `mix` can be paid with `share` of the stocks, without
## letting the algae upkeep run away.
static func affordable(turn: ScriptTurn, mix: Dictionary, share := 1.0) -> int:
	var player := turn.player
	var costs := UnitCostCalculator.new()
	var best := 1 << 30
	for r: ResourceType.Value in ResourceType.Value.values():
		var per_mix := 0
		for t: UnitType.Value in mix:
			var n: int = mix[t]
			per_mix += costs.recruitment_cost(t, player.is_degraded(BuildingType.Value.BARRACKS)).get(r, 0) * n
		if per_mix == 0:
			continue
		var stock := floori(GameResource.amount_in(player.resources, r) * share)
		best = mini(best, DartMath.trunc_div(stock, per_mix))
	var upkeep := 0
	for t: UnitType.Value in mix:
		var n: int = mix[t]
		upkeep += ConsumptionCalculator.unit_algae_consumption(t) * n
	if upkeep > 0:
		var algae := GameResource.amount_in(player.resources, ResourceType.Value.ALGAE)
		var room := algae_margin(turn) + DartMath.trunc_div(algae, 10)
		best = mini(best, DartMath.trunc_div(room, upkeep))
	var largest := 0
	for n: int in mix.values():
		largest = maxi(largest, n)
	var cap := DartMath.trunc_div(barracks_level(turn) * 100, largest)
	return clampi(mini(mini(best, cap), MAX_BATCH), 0, 1 << 30)


## Algae produced minus algae eaten each turn, all levels together.
static func algae_margin(turn: ScriptTurn) -> int:
	var made := TurnProduction.of(turn.player, turn.game.turn, turn.game.difficulty())
	var produced: int = made.get(ResourceType.Value.ALGAE, 0)
	return produced - ConsumptionCalculator.total_unit_consumption_all_levels(turn.player.units_per_level)


## Recruits `k` times `mix`, each type its own action; whether all joined.
static func recruit_mix(turn: ScriptTurn, mix: Dictionary, k: int) -> bool:
	if k <= 0:
		return false
	var all := true
	for t: UnitType.Value in mix:
		var n: int = mix[t]
		all = turn.try_perform(RecruitUnitAction.new(t, n * k)) and all
	return all


## Recruits the smallest top-up of the first of `mixes` (in order of
## preference) that lets `base` beat `enemy`; when none is enough, spends
## `share` on the first mix. Returns whether the army is judged strong
## enough afterwards.
static func top_up(
	turn: ScriptTurn,
	base: Dictionary[UnitType.Value, int],
	enemy: Callable,
	mixes: Array[Dictionary],
	planner: ArmyPlanner,
	boost: UnitBoost,
	allies := Callable(),
	needs_admiral := false,
	share := 1.0,
) -> bool:
	var usable := usable_mixes(turn, mixes)
	for mix: Dictionary in usable:
		var plus := func(k: int) -> Dictionary[UnitType.Value, int]:
			var army: Dictionary[UnitType.Value, int] = base.duplicate()
			for t: UnitType.Value in mix:
				var n: int = mix[t]
				army[t] = base.get(t, 0) + n * k
			return army
		var found: Variant = planner.smallest_winning(
			affordable(turn, mix, share), plus, enemy, boost, allies, needs_admiral
		)
		if found == null:
			continue
		var k: int = found
		return k == 0 or recruit_mix(turn, mix, k)
	if not usable.is_empty():
		recruit_mix(turn, usable[0], affordable(turn, usable[0], share))
	return false

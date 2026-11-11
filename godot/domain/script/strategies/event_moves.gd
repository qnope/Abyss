class_name EventMoves
extends RefCounted
## lib/domain/script/strategies/event_moves.dart: how the scripts meet the
## random events, one simple rule per event, played early in the turn,
## before spending. The Dart extension on ScriptTurn: each function takes
## the turn first.

const Type := RandomEventType.Value


## Answers the event waiting for a choice this turn unless `choose` is off
## (a replay that recorded its own), then goes for the wreck. With `bold`,
## the wreck is chased whatever the noise (see fetch_wreck).
static func play_events(turn: ScriptTurn, planner: ArmyPlanner, choose := true, bold := false) -> void:
	if choose:
		choose_event(turn, planner)
	fetch_wreck(turn, bold)


## Takes the first option of the event waiting for a choice this turn when
## wants_event says so and the game allows it, the prudent one otherwise.
static func choose_event(turn: ScriptTurn, planner: ArmyPlanner) -> void:
	var state := turn.player.event_state
	if not state.has_pending() or state.pending_turn != turn.number():
		return
	var pending: Type = state.pending
	var accepted := wants_event(turn, pending, planner) and turn.try_perform(ChooseEventAction.new(true))
	if not accepted:
		turn.try_perform(ChooseEventAction.new(false))


## Whether the first option of `type` is worth it now:
## - warm current: its three turns of noise keep the raids away;
## - cold current: enduring would starve the units (see _starves_in_cold)
##   and the energy margin pays the heating each turn;
## - predators: the base level holds them with `planner`'s confidence;
## - survivors: the algae margin feeds them;
## - caravan: the stock given is at least twice the stock received.
static func wants_event(turn: ScriptTurn, type: Type, planner: ArmyPlanner) -> bool:
	var state := turn.player.event_state
	match type:
		Type.WARM_CURRENT:
			return _quiet_after(turn, EventRules.EFFECT_TURNS * EventRules.WARM_NOISE_PER_TURN)
		Type.COLD_CURRENT:
			return _starves_in_cold(turn) and GrowthMoves.energy_margin(turn) >= EventRules.HEATING_ENERGY_PER_TURN
		Type.PREDATORS:
			return _holds(turn, state.predator_wave, planner)
		Type.SURVIVORS:
			var survivors: int = state.survivors if state.survivors != null else 0
			var upkeep := ConsumptionCalculator.unit_algae_consumption(UnitType.Value.HARPOONIST)
			return RecruitMoves.algae_margin(turn) >= survivors * upkeep
		Type.CARAVAN:
			return _trades_well(turn, state)
	# The storm and the wreck.
	return false


## Searches the wreck in sight, or sends a scout to it while a later turn
## is left to search it, as long as the noise keeps the raids away.
##
## A `bold` player (a faction, always under raids, that must not leave the
## wreck to a rival) ignores the noise and recruits the scout it lacks.
static func fetch_wreck(turn: ScriptTurn, bold := false) -> void:
	var player := turn.player
	var state := player.event_state
	var at := state.wreck_position
	if at == null:
		return
	if not bold and not _quiet_after(turn, EventRules.WRECK_NOISE):
		return
	var level := WreckSites.LEVEL
	if player.revealed_cells_set_on_level(level).has(at.key()):
		turn.try_perform(CollectTreasureAction.new(at.x, at.y, level, turn.random()))
		return
	var until: int = state.wreck_until_turn if state.wreck_until_turn != null else turn.number()
	if turn.number() < until:
		var scouts := player.units_on_level(level)[UnitType.Value.SCOUT].count
		if bold and scouts == 0:
			turn.try_perform(RecruitUnitAction.new(UnitType.Value.SCOUT, 1))
		turn.try_perform(ExploreAction.new(at.x, at.y, level))


## Whether `noise` more keeps the gauge under the threshold, with no raid
## announced.
static func _quiet_after(turn: ScriptTurn, noise: int) -> bool:
	var raids := turn.player.raid_state
	return not raids.is_incoming() and raids.noise + noise < NoiseRules.THRESHOLD


## Whether the algae stock and the algae margin, with the cut of an endured
## cold current, run out within its turns: units would be lost.
static func _starves_in_cold(turn: ScriptTurn) -> bool:
	var player := turn.player
	var made := TurnProduction.of(player, turn.number(), turn.game.difficulty())
	var produced: int = made.get(ResourceType.Value.ALGAE, 0)
	var cut := produced - DartMath.trunc_div(produced * (100 - EventRules.CURRENT_PERCENT), 100)
	var stock := GameResource.amount_in(player.resources, ResourceType.Value.ALGAE)
	return stock + EventRules.EFFECT_TURNS * (RecruitMoves.algae_margin(turn) - cut) < 0


static func _holds(turn: ScriptTurn, wave: MonsterLair, planner: ArmyPlanner) -> bool:
	return wave != null and BattleMoves.holds(turn, wave, planner)


static func _trades_well(turn: ScriptTurn, state: EventState) -> bool:
	if state.trade_from == null or state.trade_to == null:
		return false
	var from: ResourceType.Value = state.trade_from
	var to: ResourceType.Value = state.trade_to
	var resources := turn.player.resources
	return GameResource.amount_in(resources, from) >= 2 * GameResource.amount_in(resources, to)

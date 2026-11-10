class_name PredatorsEffect
extends EventEffect
## lib/domain/event/effects/predators_effect.dart: a shoal of predators, a
## wave of PREDATORS_POWER_PERCENT % of a raid built at the draw. Faced, it
## strikes the base at the end of the turn of the choice like a raid that
## does not count as one; baited, it takes BAIT_ALGAE_PERCENT % of the algae
## and swims away.


## Never on top of a raid hitting the base at the end of the next turn.
func allowed_at(_game: Game, player: Player, ended_turn: int) -> bool:
	var raid := player.raid_state
	return not (raid.is_incoming() and raid.arrival_turn == ended_turn + 1)


func on_draw(game: Game, player: Player, _turn: int, random: DartRandom) -> void:
	var factions := game.factions().size() if player.id == game.human_player_id else 0
	var percent := DartMath.trunc_div(
		Difficulty.monster_percent_for(game.difficulty(), false, factions)
			* EventRules.PREDATORS_POWER_PERCENT,
		100,
	)
	player.event_state.predator_wave = RaidWaveFactory.from_total_noise(
		player.raid_state.total_noise, random, percent
	)


## Faced, the wave strikes at the end of `turn` (see strike).
func apply(_game: Game, player: Player, accept: bool, turn: int, _random: DartRandom = null) -> void:
	var state := player.event_state
	if accept:
		state.predators_turn = turn
		return
	var algae: GameResource = player.resources.get(ResourceType.Value.ALGAE)
	if algae != null:
		algae.amount -= DartMath.trunc_div(algae.amount * EventRules.BAIT_ALGAE_PERCENT, 100)
	state.clear_predators()


## Fights the faced wave due by the end of `ended_turn` with the units of
## the base level and the rampart, records it in the history and forgets
## it. Returns null when no wave strikes.
static func strike(player: Player, ended_turn: int, random: DartRandom) -> RaidReport:
	var state := player.event_state
	var due: Variant = state.predators_turn
	var wave := state.predator_wave
	if due == null or due > ended_turn:
		return null
	state.clear_predators()
	if wave == null:
		return null
	var report := RaidBattle.fight(
		player, wave, ended_turn, random, EventRules.PREDATORS_LOOT_PERCENT, true
	)
	player.add_history_entry(report.to_entry())
	return report

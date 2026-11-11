class_name TurnResolver
extends RefCounted
## lib/domain/turn/turn_resolver.dart: the end of a turn for the whole game:
## each standing player's base, raid, kraken wave and event, then the
## Leviathan, the fall of the factions, the explorations, the
## reinforcements and the objectives; the turn moves on and the game may be
## lost. The result is the human's.


## `random` drives the raid fights and the random events; pass a seeded one
## for a reproducible turn (null is Dart's own die). `attacks` are the
## attacks on the human fought this turn, to report in the result.
func resolve(game: Game, random: DartRandom = null, attacks: Array[FactionAttackReport] = []) -> TurnResult:
	var previous_turn := game.turn
	var human_id := game.human_player_id
	var human_result: TurnResult = null
	var raid := RaidTurnOutcome.new()
	var volcano := VolcanoTurnOutcome.new()
	var event := EventTurnOutcome.new()
	var factions := game.factions().size()

	for player: Player in game.players.values():
		if player.has_fallen():
			continue
		var is_faction := player.id != human_id
		var result := PlayerTurnResolver.resolve(
			player, previous_turn, PearlIncome.as_production(game, player.id), game.difficulty(), is_faction
		)
		var outcome := RaidResolver.resolve(player, previous_turn, random, game.difficulty(), is_faction, factions)
		var volcano_outcome := VolcanoResolver.resolve(
			player, previous_turn, random, game.difficulty(), is_faction, factions
		)
		var event_outcome := EventResolver.resolve(game, player, previous_turn, random)
		if not is_faction:
			human_result = result
			raid = outcome
			volcano = volcano_outcome
			event = event_outcome

	var leviathan := LeviathanResolver.resolve(game, random)
	FactionFall.apply(game)
	var explorations := ExplorationResolver.resolve(game)
	var reinforcements := ReinforcementResolver.resolve(game)
	# After the moves, so an exploration or a raid counts the same turn.
	var objectives: Dictionary[String, Array] = {}
	for player: Player in game.players.values():
		objectives[player.id] = ObjectiveResolver.resolve(game, player)
	game.turn += 1
	var status: Variant = DefeatChecker.check(game)
	if status != null:
		game.status = status

	var reports: Array[FactionAttackReport] = attacks.duplicate()
	if leviathan.report != null:
		reports.append(leviathan.report)
	var completed: Array[ObjectiveCompletion] = []
	completed.assign(objectives[human_id])
	return TurnResult.new(
		human_result.changes,
		previous_turn,
		game.turn,
		human_result.had_recruited_units,
		human_result.deactivated_buildings,
		human_result.lost_units,
		explorations,
		reinforcements,
		raid.report,
		raid.announced,
		raid.announced_turn,
		volcano.report,
		volcano.announced,
		event.drawn,
		event.defaulted,
		event.predators,
		completed,
		TemporaryObjectives.ended_by(event),
		reports,
		leviathan.report,
		leviathan.announced,
	)

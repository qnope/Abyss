extends TestCase
## test/domain/objective/temporary/temporary_objectives_test.dart: the
## objectives the events of a player set. Its last two tests choose through
## ChooseEventAction and wait for `action`; their twins below choose through
## the effect, as that action does.

const WRECK := TemporaryObjectiveKind.Value.WRECK
const PREDATORS := TemporaryObjectiveKind.Value.PREDATORS
const Outcome := TemporaryObjectiveOutcome.Value


func test_temporary_objectives_active_of_none_without_a_wreck_on_the_map_nor_predators_faced() -> void:
	var player := EventSamples.wreck_player()
	assert_eq(TemporaryObjectives.active_of(EventSamples.wreck_game(player), player).size(), 0)


func test_temporary_objectives_active_of_a_wreck_on_the_map_asks_to_search_it_before_its_last_turn() -> void:
	var player := EventSamples.wreck_player()
	var game := EventSamples.wreck_game(player, null, 13)
	WreckEffect.new().on_draw(game, player, 12, DartRandom.new(2))
	var active := TemporaryObjectives.active_of(game, player)
	assert_eq(active.size(), 1)
	assert_eq([active[0].kind, active[0].last_turn], [WRECK, 17])


func test_temporary_objectives_active_of_a_searched_wreck_is_no_longer_to_search() -> void:
	var player := EventSamples.wreck_player()
	var game := EventSamples.wreck_game(player, null, 13)
	WreckEffect.new().on_draw(game, player, 12, DartRandom.new(2))
	WreckEffect.searched(player, player.event_state.wreck_position)
	assert_eq(TemporaryObjectives.active_of(game, player).size(), 0)


## Not in the Dart file: the wreck is still to search during its last turn,
## no longer after it.
func test_a_wreck_is_to_search_through_its_last_turn() -> void:
	var player := EventSamples.wreck_player()
	var game := EventSamples.wreck_game(player, null, 17)
	WreckEffect.new().on_draw(game, player, 12, DartRandom.new(2))
	assert_eq(TemporaryObjectives.active_of(game, player).size(), 1)
	game.turn = 18
	assert_eq(TemporaryObjectives.active_of(game, player).size(), 0)


## Not in the Dart file: "predators faced are to repel by the end of the
## turn", chosen as ChooseEventAction does.
func test_predators_faced_are_to_repel_by_the_end_of_the_turn() -> void:
	var game := _predators_game(true)
	var active := TemporaryObjectives.active_of(game, game.human_player())
	assert_eq(active.size(), 1)
	assert_eq([active[0].kind, active[0].last_turn], [PREDATORS, 12])
	game.turn = 13
	assert_eq(TemporaryObjectives.active_of(game, game.human_player()).size(), 0)


## Not in the Dart file: "predators baited or not chosen yet bring no
## objective", chosen as ChooseEventAction does.
func test_predators_baited_or_not_chosen_yet_bring_no_objective() -> void:
	for accept: Variant in [false, null]:
		var game := _predators_game(accept)
		assert_eq(TemporaryObjectives.active_of(game, game.human_player()).size(), 0, str(accept))


## Not in the Dart file: the objectives a turn ended, from what its events
## did, the wreck first.
func test_ended_by_reads_the_wreck_then_the_predators_of_the_turn() -> void:
	assert_eq(_ended(EventTurnOutcome.new()), [])
	var outcome := EventTurnOutcome.new(null, null, _report(12, true), WreckEnding.new(true, 17))
	assert_eq(_ended(outcome), [[WRECK, 17, Outcome.DONE], [PREDATORS, 12, Outcome.DONE]])
	outcome = EventTurnOutcome.new(null, null, _report(9, false), WreckEnding.new(false, 21))
	assert_eq(_ended(outcome), [[WRECK, 21, Outcome.EXPIRED], [PREDATORS, 9, Outcome.FAILED]])


## `_predatorsGame`: the game of turn 12 whose predators are faced when
## `accept` is true, baited when false, still waiting when null.
func _predators_game(accept: Variant) -> Game:
	var player := EventSamples.threatened_player()
	var game := Game.single_player(player)
	game.turn = 12
	if accept != null:
		var faced: bool = accept
		EventEffects.apply(game, player, RandomEventType.Value.PREDATORS, faced, game.turn)
		player.event_state.clear_pending()
	return game


func _report(turn: int, victory: bool) -> RaidReport:
	var wave := EventSamples.predator_test_wave()
	return RaidReport.new(turn, victory, wave, HistorySamples.fight(victory), 0, {}, {}, {}, {}, {}, {})


func _ended(outcome: EventTurnOutcome) -> Array:
	var ends: Array = []
	for end: TemporaryObjectiveEnd in TemporaryObjectives.ended_by(outcome):
		ends.append([end.objective.kind, end.objective.last_turn, end.outcome])
	return ends

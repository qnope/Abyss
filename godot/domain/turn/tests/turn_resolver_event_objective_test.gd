extends TestCase
## test/domain/turn/turn_resolver_event_objective_test.dart: the temporary
## objectives of the wreck and the predators ended by a turn.

const Kind := TemporaryObjectiveKind.Value
const Outcome := TemporaryObjectiveOutcome.Value


## Game of turn `turn` with a wreck sunk at the end of turn 12, to be
## searched through turn 17, already in sight.
static func _wreck_game(turn := 13) -> Game:
	var player := EventSamples.wreck_player()
	var game := EventSamples.wreck_game(player, null, turn)
	WreckEffect.new().on_draw(game, player, 12, DartRandom.new(2))
	player.add_revealed_cell(1, player.event_state.wreck_position)
	return game


## Game of turn 12 whose predators are faced (`accept`) or baited, by a base
## holding `harpoonists`.
static func _predators_game(accept: bool, harpoonists := 0) -> Game:
	var player := EventSamples.threatened_player({UnitType.Value.HARPOONIST: harpoonists})
	var game := Game.single_player(player)
	game.turn = 12
	ChooseEventAction.new(accept).execute(game, player)
	return game


## The single objective of an event that ended with the turn of `game`.
func _end_of(game: Game) -> TemporaryObjectiveEnd:
	var ends := TurnResolver.new().resolve(game, DartRandom.new(4)).temporary_objectives
	assert_eq(ends.size(), 1)
	return ends[0]


func test_a_wreck_searched_during_the_turn_is_reported_done_once() -> void:
	var game := _wreck_game(14)
	var at := game.human_player().event_state.wreck_position
	var search := CollectTreasureAction.new(at.x, at.y)
	assert_true(ActionExecutor.new().execute(search, game, game.human_player()).is_success)

	var end := _end_of(game)

	assert_eq(end.objective.kind, Kind.WRECK)
	assert_eq(end.objective.last_turn, 17)
	assert_eq(end.outcome, Outcome.DONE)
	assert_true(TurnResolver.new().resolve(game).temporary_objectives.is_empty())


func test_a_wreck_left_to_sink_is_reported_expired_after_its_last_turn() -> void:
	var game := _wreck_game()
	for turn: int in range(13, 17):
		var result := TurnResolver.new().resolve(game)
		assert_true(result.temporary_objectives.is_empty(), "turn %d" % turn)

	var end := _end_of(game)

	assert_eq(end.objective.kind, Kind.WRECK)
	assert_eq(end.objective.last_turn, 17)
	assert_eq(end.outcome, Outcome.EXPIRED)
	assert_true(TurnResolver.new().resolve(game).temporary_objectives.is_empty())


func test_predators_repelled_are_reported_done() -> void:
	var game := _predators_game(true, 30)

	var end := _end_of(game)

	assert_eq(end.objective.kind, Kind.PREDATORS)
	assert_eq(end.objective.last_turn, 12)
	assert_eq(end.outcome, Outcome.DONE)
	assert_true(TurnResolver.new().resolve(game).temporary_objectives.is_empty())


func test_predators_that_win_the_fight_are_reported_failed() -> void:
	var game := _predators_game(true)

	var end := _end_of(game)

	assert_eq(end.objective.kind, Kind.PREDATORS)
	assert_eq(end.outcome, Outcome.FAILED)


func test_baited_predators_report_nothing() -> void:
	var game := _predators_game(false)
	assert_true(TurnResolver.new().resolve(game).temporary_objectives.is_empty())

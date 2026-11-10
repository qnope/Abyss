extends TestCase
## test/domain/action/explore_action_storm_test.dart: a storm forbids
## exploring while it lasts.


func test_a_storm_drawn_at_the_end_of_turn_12_forbids_exploring_on_13_and_14() -> void:
	var game := ActionSamples.explore_game()
	game.turn = 12
	var player := game.human_player()
	player.event_state.schedule(100)
	StormEffect.new().apply(game, player, true, game.turn + 1)
	var reasons: Array = []
	for turn: int in range(13, 16):
		game.turn = turn
		reasons.append(ExploreAction.new(2, 2).validate(game, player).reason)
		EventResolver.resolve(game, player, turn)
	assert_eq(reasons, [
		ActionFailure.Value.STORM_BLOCKS_EXPLORATION, ActionFailure.Value.STORM_BLOCKS_EXPLORATION, null,
	])


func test_an_exploration_ordered_before_the_storm_still_resolves() -> void:
	var game := ActionSamples.explore_game()
	game.turn = 12
	var player := game.human_player()
	ExploreAction.new(2, 1).execute(game, player)
	StormEffect.new().apply(game, player, true, 13)
	assert_eq(ExplorationResolver.resolve(game).size(), 1)
	assert_true(player.pending_explorations.is_empty())

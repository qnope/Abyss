extends MapSheetCase
## test/presentation/screens/game/game_screen_map_wreck_test.dart: the
## countdown of the wreck, where it lies.


func _wreck(x := 4, y := 4, until := 6) -> void:
	game.turn = 4
	human.event_state.wreck_position = GridPosition.new(x, y)
	human.event_state.wreck_until_turn = until


func test_counts_the_current_turn_through_the_last_one() -> void:
	_wreck()
	assert_eq(WreckNotice.at(game, 4, 4, 1), "Épave : encore 3 tours")
	game.turn = 6
	assert_eq(WreckNotice.at(game, 4, 4, 1), "Épave : encore 1 tour")


func test_says_nothing_elsewhere() -> void:
	_wreck()
	assert_eq(WreckNotice.at(game, 3, 4, 1), "")
	assert_eq(WreckNotice.at(game, 4, 3, 1), "")
	assert_eq(WreckNotice.at(game, 4, 4, 2), "")


func test_says_nothing_without_a_wreck() -> void:
	assert_eq(WreckNotice.at(game, 4, 4, 1), "")
	human.event_state.wreck_position = GridPosition.new(4, 4)
	assert_eq(WreckNotice.at(game, 4, 4, 1), "")


func test_follows_the_language() -> void:
	_wreck()
	use_language("en")
	assert_eq(WreckNotice.at(game, 4, 4, 1), "Wreck: 3 turns left")

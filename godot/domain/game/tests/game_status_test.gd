extends TestCase
## test/domain/game/game_status_test.dart: where a game stands.

const Status := GameStatus.Value


func test_game_status_has_exactly_4_values() -> void:
	assert_eq(Status.size(), 4)


func test_game_status_values_are_playing_victory_defeat_free_play() -> void:
	assert_eq(Status.values(), [Status.PLAYING, Status.VICTORY, Status.DEFEAT, Status.FREE_PLAY])


func test_game_status_field_game_defaults_to_game_status_playing() -> void:
	var p := Player.new("A", "a", 5, 5)
	var game := Game.new(p.id, {p.id: p})
	assert_eq(game.status, Status.PLAYING)


func test_game_status_field_game_single_player_defaults_to_game_status_playing() -> void:
	var game := Game.single_player(Player.new("A", "a", 5, 5))
	assert_eq(game.status, Status.PLAYING)


func test_game_status_field_status_can_be_set_to_each_value() -> void:
	var game := Game.single_player(Player.new("A", "a", 5, 5))
	for status: Status in Status.values():
		game.status = status
		assert_eq(game.status, status)


## Not in the Dart file: the names the snapshots write.
func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(
		DartEnum.names(Status), PackedStringArray(["playing", "victory", "defeat", "freePlay"])
	)

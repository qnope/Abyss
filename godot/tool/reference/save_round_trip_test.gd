extends TestCase
## The saves of whole games (SaveRoundTrip), on the short reference games:
## saved and loaded as every turn starts, each loaded game is the game that
## was saved, and one loaded at a few turns plays on as the game never
## saved. `tool/godot_reference.sh` does it on the other games, as the long
## cases `saves-<game>` (tool/replay/README.md).


func test_a_game_without_moves_loads_as_it_was_saved_at_every_turn_and_plays_on_alike() -> void:
	var trip := SaveRoundTrip.new(CommittedGame.named("idle-normal"), 1, [1, 20, 47] as Array[int])
	assert_eq(trip.problems(), PackedStringArray())
	assert_eq(trip.checker.checked, 48)
	assert_eq(trip.resumed_turns, 48 + 29 + 2)


func test_a_game_with_moves_loads_as_it_was_saved_at_every_turn_and_plays_on_alike() -> void:
	var trip := SaveRoundTrip.new(CommittedGame.named("economy-hard"), 1, [2, 14, 26] as Array[int])
	assert_eq(trip.problems(), PackedStringArray())
	assert_eq(trip.checker.checked, 27)
	assert_eq(trip.resumed_turns, 26 + 14 + 2)

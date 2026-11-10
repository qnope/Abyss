extends TestCase
## How a map grows with the number of players. Dart has no test file for
## map_layout.dart: its sizes are held by map_generator_players_test.dart,
## whose 'rejects a player count off the 1 to 11 range' is the last test
## here, and by the section layout of the vectors.


func test_a_map_is_20_wide_up_to_3_players_26_up_to_6_32_up_to_11() -> void:
	var sizes := {1: 20, 2: 20, 3: 20, 4: 26, 6: 26, 7: 32, 11: 32}
	for players: int in sizes:
		assert_eq(MapLayout.size_for(players), sizes[players], "%d players" % players)


func test_one_more_post_of_each_kind_for_each_two_players_past_the_first() -> void:
	assert_eq(MapLayout.extra_posts_for(1), 0)
	assert_eq(MapLayout.extra_posts_for(2), 0)
	assert_eq(MapLayout.extra_posts_for(3), 1)
	assert_eq(MapLayout.extra_posts_for(11), 5)


func test_a_larger_map_holds_more_lairs() -> void:
	assert_eq(MapLayout.lair_range_for(20), Vector2i(5, 10))
	assert_eq(MapLayout.lair_range_for(26), Vector2i(8, 16))
	assert_eq(MapLayout.lair_range_for(32), Vector2i(12, 25))


## Dart throws an ArgumentError: the port logs an error and answers REFUSED.
func test_rejects_a_player_count_off_the_1_to_11_range() -> void:
	expect_error("MapLayout: playerCount 0 must be 1 to 11")
	assert_eq(MapLayout.size_for(0), MapLayout.REFUSED)
	expect_error("MapLayout: playerCount 12 must be 1 to 11")
	assert_eq(MapLayout.size_for(12), MapLayout.REFUSED)
	expect_error("MapLayout: playerCount 0 must be 1 to 11")
	assert_eq(MapLayout.extra_posts_for(0), MapLayout.REFUSED)

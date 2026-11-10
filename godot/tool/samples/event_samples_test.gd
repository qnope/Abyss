extends TestCase
## The players, games and maps EventSamples builds, as the Dart helpers of
## the random events do.


func test_an_event_player_and_its_game() -> void:
	var player := EventSamples.event_player()
	assert_eq([player.id, player.name], ["p1", "Test"])
	assert_null(player.event_state.next_draw_turn)
	var game := EventSamples.event_game(player, 7)
	assert_true(game.human_player() == player)
	assert_eq(game.turn, 7)
	assert_eq(EventSamples.event_game(player).turn, 1)


func test_a_wreck_map_holds_the_contents_given() -> void:
	var map := EventSamples.wreck_map(5, {Vector2i(2, 1): CellContentType.Value.RUINS})
	assert_eq([map.width, map.height, map.cells.size(), map.map_seed], [5, 5, 25, 7])
	assert_eq(map.cell_at(2, 1).content, CellContentType.Value.RUINS)
	assert_eq(map.cell_at(1, 2).content, CellContentType.Value.EMPTY)
	assert_eq(EventSamples.wreck_map().width, 9)


func test_the_square_and_the_ring_around_the_base() -> void:
	var square := EventSamples.square_around(4, 4, 1)
	assert_eq(square.size(), 9)
	assert_eq([square[0].key(), square[8].key()], [Vector2i(3, 3), Vector2i(5, 5)])
	var ring := EventSamples.wreck_ring()
	assert_eq(ring.size(), 16)
	assert_eq([ring[0].key(), ring[15].key()], [Vector2i(2, 2), Vector2i(6, 6)])


func test_a_wreck_player_and_its_game() -> void:
	var player := EventSamples.wreck_player()
	assert_eq([player.base_x, player.base_y], [4, 4])
	assert_eq(player.revealed_cells_on_level(1).size(), 9)
	assert_eq(player.units_on_level(1)[UnitType.Value.SCOUT].count, 1)
	assert_eq(player.units_on_level(1)[UnitType.Value.HARPOONIST].count, 0)
	assert_eq(player.event_state.next_draw_turn, 100)
	var few := EventSamples.wreck_player(EventSamples.square_around(4, 4, 0), 3)
	assert_eq(few.revealed_cells_on_level(1).size(), 1)
	assert_eq(few.units_on_level(1)[UnitType.Value.SCOUT].count, 3)
	var game := EventSamples.wreck_game(player)
	assert_eq([game.turn, game.levels[1].width], [12, 9])
	var map := EventSamples.wreck_map(4)
	assert_true(EventSamples.wreck_game(player, map, 3).levels[1] == map)

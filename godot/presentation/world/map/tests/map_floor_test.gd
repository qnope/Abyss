extends MapTestCase
## The floor and the contents of the map: a tile per cell, dark and lower in
## the fog, and what stands on the cells seen.


func test_the_floor_of_a_terrain_is_lighter_and_higher_than_the_fog() -> void:
	for terrain: TerrainType.Value in TerrainType.Value.values():
		var seen := WorldModels.terrain(terrain, true)
		var hidden := WorldModels.terrain(terrain, false)
		assert_ne(seen.colour, hidden.colour)
		assert_eq(hidden.colour, MapPalette.FOG)
		assert_true(hidden.colour.v < seen.colour.v)
		assert_true(hidden.height < seen.height)
		assert_eq(seen.colour, MapPalette.TERRAINS[terrain])


func test_every_terrain_has_a_colour_of_its_own() -> void:
	assert_eq(MapPalette.TERRAINS.size(), TerrainType.Value.size())
	var colours: Dictionary[Color, bool] = {}
	for colour: Color in MapPalette.TERRAINS.values():
		colours[colour] = true
	assert_eq(colours.size(), TerrainType.Value.size())


func test_lays_a_tile_per_cell_lit_where_seen_and_under_the_fog_where_not() -> void:
	var state := level_of(4, 3, [Vector2i(1, 1), Vector2i(2, 1)])
	var tiles := MapTiles.new()
	add_cleanup(tiles.free)
	tiles.show_looks(MapLooks.of(state), 4, 3)
	var lit := 0
	var fog := 0
	for part_name in tiles.counts:
		if String(part_name).begins_with("Lit"):
			lit += tiles.counts[part_name]
		else:
			fog += tiles.counts[part_name]
	assert_eq([lit, fog], [2, 10])
	assert_eq(tiles.get_child_count(), tiles.counts.size())


func test_the_tiles_of_a_level_are_laid_again_in_place_of_the_ones_before() -> void:
	var tiles := MapTiles.new()
	add_cleanup(tiles.free)
	var looks := MapLooks.of(level_of(3, 3, [], true))
	tiles.show_looks(looks, 3, 3, 1)
	tiles.show_looks(looks, 3, 3, 2)
	var total := 0
	for part_name in tiles.counts:
		total += tiles.counts[part_name]
	assert_eq(total, 9)
	assert_eq(tiles.get_child_count(), tiles.counts.size())


func test_the_floor_is_the_same_every_time_and_turns_by_quarters() -> void:
	assert_eq(MapTiles.hash_of(3, 4), MapTiles.hash_of(3, 4))
	assert_ne(MapTiles.hash_of(3, 4), MapTiles.hash_of(4, 3))
	var turns: Dictionary[int, bool] = {}
	for x in 12:
		for y in 12:
			var turn := MapTiles.turn_of(x, y)
			assert_true(turn.is_equal_approx(Basis(Vector3.UP, roundi(turn.get_euler().y / (PI / 2.0)) * PI / 2.0)))
			turns[roundi(turn.get_euler().y * 10.0)] = true
	assert_true(turns.size() >= 4)


func test_stands_the_contents_on_their_tiles() -> void:
	var state := level_of(6, 6, [Vector2i(0, 0)], true)
	put(state, 1, 1, Content.RUINS)
	put(state, 2, 2, Content.VOLCANIC_KERNEL)
	var contents := MapContents.new()
	add_cleanup(contents.free)
	contents.show_looks(MapLooks.of(state), 6, 6)
	assert_eq(contents.by_cell.keys(), [Vector2i(1, 1), Vector2i(2, 2)])
	assert_eq(contents.by_cell[Vector2i(1, 1)].position, MapGrid.at(1, 1, 6, 6))
	assert_eq(contents.by_cell[Vector2i(2, 2)].position, MapGrid.at(2, 2, 6, 6) + Vector3(0.5, 0.0, 0.5))
	assert_eq(contents.by_cell[Vector2i(1, 1)].name, &"Cell1_1")
	assert_false(contents.by_cell[Vector2i(1, 1)] is MapStandIn)


func test_a_wreck_in_the_fog_stands_on_the_lower_tile() -> void:
	var state := level_of(4, 4)
	put(state, 1, 1, Content.WRECK)
	var contents := MapContents.new()
	add_cleanup(contents.free)
	contents.show_looks(MapLooks.of(state), 4, 4)
	assert_almost_eq(contents.by_cell[Vector2i(1, 1)].position.y, -TerrainLook.FOG_DROP, 1e-5)


func test_stands_other_contents_in_place_of_the_first() -> void:
	var state := level_of(4, 4, [], true)
	put(state, 1, 1, Content.RUINS)
	var contents := MapContents.new()
	add_cleanup(contents.free)
	contents.show_looks(MapLooks.of(state), 4, 4)
	put(state, 2, 2, Content.RESOURCE_BONUS)
	contents.show_looks(MapLooks.of(state), 4, 4)
	assert_eq(contents.get_child_count(), 2)
	assert_eq(contents.by_cell.size(), 2)
	state = level_of(4, 4, [], true)
	contents.show_looks(MapLooks.of(state), 4, 4)
	assert_eq(contents.get_child_count(), 0)
	assert_true(contents.by_cell.is_empty())

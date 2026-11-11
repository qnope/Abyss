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


func test_lays_a_tile_per_cell_dark_and_lower_where_not_seen() -> void:
	var state := level_of(4, 3, [Vector2i(1, 1), Vector2i(2, 1)])
	var tiles := MapTiles.new()
	add_cleanup(tiles.free)
	tiles.show_looks(MapLooks.of(state), 4, 3)
	assert_eq(tiles.multimesh.instance_count, 12)
	var seen := 1 * 4 + 1
	var fog := 0
	assert_eq(tiles.colours[fog], MapPalette.FOG)
	assert_true(tiles.colours[fog].v < tiles.colours[seen].v)
	assert_eq(tiles.tops[seen], 0.0)
	assert_almost_eq(tiles.tops[fog], -TerrainLook.FOG_DROP, 1e-6)
	assert_eq(tiles.tops.size(), 12)
	assert_eq(tiles.colours.size(), 12)


func test_every_other_tile_is_a_little_lighter() -> void:
	var tiles := MapTiles.new()
	add_cleanup(tiles.free)
	tiles.show_looks(MapLooks.of(level_of(3, 1, [], true)), 3, 1)
	var plain := MapPalette.TERRAINS[TerrainType.Value.PLAIN]
	assert_eq(tiles.colours[0], plain)
	assert_eq(tiles.colours[1], plain.lightened(MapPalette.CHECKER))
	assert_eq(tiles.colours[2], plain)


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
	assert_true(contents.by_cell[Vector2i(1, 1)] is MapStandIn)


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

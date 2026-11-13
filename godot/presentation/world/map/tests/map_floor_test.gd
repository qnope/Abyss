extends MapTestCase
## The floor of the map: a tile per cell, dark and lower in the fog, laid again
## only when it changed.


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


func test_the_same_floor_again_keeps_its_layers() -> void:
	var tiles := _tiles()
	var state := level_of(4, 3, [Vector2i(1, 1)])
	tiles.show_looks(MapLooks.of(state), 4, 3)
	var layers := tiles.get_children()
	var counts := tiles.counts.duplicate()
	tiles.show_looks(MapLooks.of(state), 4, 3)
	assert_eq(tiles.get_children(), layers, "the very layers laid first")
	assert_eq(tiles.counts, counts)


func test_a_cell_newly_seen_relays_the_floor_as_a_fresh_one() -> void:
	var tiles := _tiles()
	var state := level_of(4, 3, [Vector2i(1, 1)])
	tiles.show_looks(MapLooks.of(state), 4, 3)
	var before := tiles.get_child(0)
	state.revealed[Vector2i(2, 1)] = true
	tiles.show_looks(MapLooks.of(state), 4, 3)
	var fresh := _tiles()
	fresh.show_looks(MapLooks.of(state), 4, 3)
	assert_eq(laid(tiles), laid(fresh))
	assert_eq(tiles.counts, fresh.counts)
	assert_false(is_instance_valid(before), "the layers before are gone")


func test_another_level_or_size_relays_the_floor_and_the_first_comes_back_as_it_was() -> void:
	var tiles := _tiles()
	var looks := MapLooks.of(level_of(3, 3, [], true))
	tiles.show_looks(looks, 3, 3, 1)
	var first := laid(tiles)
	tiles.show_looks(looks, 3, 3, 3)
	assert_ne(laid(tiles), first, "the tiles of another model")
	var third := tiles.get_children()
	tiles.show_looks(looks, 3, 3, 4)
	assert_eq(tiles.get_children(), third, "the levels under the third share its floor")
	tiles.show_looks(MapLooks.of(level_of(4, 3, [], true)), 4, 3, 4)
	assert_eq(tiles.counts.values().reduce(func(a: int, b: int) -> int: return a + b, 0), 12)
	tiles.show_looks(looks, 3, 3, 1)
	assert_eq(laid(tiles), first)


func test_the_layers_kept_take_the_shadows_as_the_ones_laid_anew() -> void:
	var tiles := _tiles()
	var looks := MapLooks.of(level_of(3, 3, [], true))
	var parts := MapScenery.parts(MapScenery.TERRAINS[0])
	tiles.show_looks(looks, 3, 3)
	tiles.receive_shadows(true)
	tiles.show_looks(looks, 3, 3)
	for layer: MultiMeshInstance3D in tiles.get_children():
		assert_eq(layer.multimesh.mesh, parts[layer.name], "the model's own, which takes them")
	tiles.receive_shadows(false)
	for layer: MultiMeshInstance3D in tiles.get_children():
		assert_eq(layer.multimesh.mesh, ShadowlessMesh.of(parts[layer.name]))


func _tiles() -> MapTiles:
	var tiles := MapTiles.new()
	add_cleanup(tiles.free)
	return tiles

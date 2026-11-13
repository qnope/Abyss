extends MapTestCase
## What stands on the cells of the map: each content on the top of its tile.

var _contents: MapContents


func before_each() -> void:
	_contents = mounted(MapContents.new()) as MapContents


func test_stands_the_contents_on_their_tiles() -> void:
	var state := level_of(6, 6, [Vector2i(0, 0)], true)
	put(state, 1, 1, Content.RUINS)
	put(state, 2, 2, Content.VOLCANIC_KERNEL)
	_contents.show_looks(MapLooks.of(state), 6, 6)
	assert_eq(_contents.by_cell.keys(), [Vector2i(1, 1), Vector2i(2, 2)])
	assert_eq(_contents.by_cell[Vector2i(1, 1)].position, MapGrid.at(1, 1, 6, 6))
	assert_eq(_contents.by_cell[Vector2i(2, 2)].position, MapGrid.at(2, 2, 6, 6) + Vector3(0.5, 0.0, 0.5))
	assert_eq(_contents.by_cell[Vector2i(1, 1)].name, &"Cell1_1")
	assert_false(_contents.by_cell[Vector2i(1, 1)] is MapStandIn)


func test_a_wreck_in_the_fog_stands_on_the_lower_tile() -> void:
	var state := level_of(4, 4)
	put(state, 1, 1, Content.WRECK)
	_contents.show_looks(MapLooks.of(state), 4, 4)
	assert_almost_eq(_contents.by_cell[Vector2i(1, 1)].position.y, -TerrainLook.FOG_DROP, 1e-5)


func test_stands_other_contents_in_place_of_the_first() -> void:
	var state := level_of(4, 4, [], true)
	put(state, 1, 1, Content.RUINS)
	_contents.show_looks(MapLooks.of(state), 4, 4)
	put(state, 2, 2, Content.RESOURCE_BONUS)
	_contents.show_looks(MapLooks.of(state), 4, 4)
	assert_eq(_contents.get_child_count(), 2)
	assert_eq(_contents.by_cell.size(), 2)
	state = level_of(4, 4, [], true)
	_contents.show_looks(MapLooks.of(state), 4, 4)
	assert_eq(_contents.get_child_count(), 0)
	assert_true(_contents.by_cell.is_empty())

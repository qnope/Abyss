extends TestCase
## test/domain/map/volcano_footprint_test.dart: the 2x2 volcano read from
## any of its cells. 'migrate completes the volcano on every level of a
## game' never comes, nor `migrate`: it runs complete_legacy() on the levels
## of a Hive save being loaded, and the Godot saves are not those.

const Content := CellContentType.Value
const PARTS: Array[Vector2i] = [Vector2i(11, 10), Vector2i(10, 11), Vector2i(11, 11)]


func test_anchor_of_each_of_the_four_cells_resolves_to_the_anchor() -> void:
	var map := _map()
	for cell: Vector2i in [Vector2i(10, 10)] + PARTS:
		var anchor := VolcanoFootprint.anchor_of(map, cell.x, cell.y)
		assert_not_null(anchor, str(cell))
		assert_true(GridPosition.new(10, 10).equals(anchor), str(cell))


func test_anchor_of_any_other_cell_has_no_anchor() -> void:
	var map := _map()
	assert_null(VolcanoFootprint.anchor_of(map, 9, 10))
	assert_null(VolcanoFootprint.anchor_of(map, 12, 12))


func test_anchor_of_a_part_with_no_anchor_beside_it_resolves_to_nothing() -> void:
	var map := _map(false)
	_put(map, 15, 15, Content.VOLCANIC_KERNEL_PART)
	assert_null(VolcanoFootprint.anchor_of(map, 15, 15))


func test_tap_target_a_tap_on_any_part_targets_the_anchor() -> void:
	var target := VolcanoFootprint.tap_target(_map(), {}, 11, 11)
	assert_eq(target.position.key(), Vector2i(10, 10))


func test_tap_target_the_volcano_counts_as_seen_when_any_of_its_cells_is() -> void:
	var map := _map()
	var seen: Dictionary[Vector2i, bool] = {Vector2i(11, 11): true}
	assert_true(VolcanoFootprint.tap_target(map, seen, 10, 10).is_revealed)
	assert_false(VolcanoFootprint.tap_target(map, {}, 10, 10).is_revealed)


func test_tap_target_another_cell_targets_itself_and_keeps_its_own_visibility() -> void:
	var map := _map()
	var seen: Dictionary[Vector2i, bool] = {Vector2i(3, 3): true}
	var target := VolcanoFootprint.tap_target(map, seen, 3, 3)
	assert_eq(target.position.key(), Vector2i(3, 3))
	assert_true(target.is_revealed)
	assert_false(VolcanoFootprint.tap_target(map, seen, 4, 4).is_revealed)


func test_complete_legacy_grows_a_1x1_kernel_saved_before_the_footprint_to_2x2() -> void:
	var map := _map(false)
	VolcanoFootprint.complete_legacy(map)
	for cell: Vector2i in PARTS:
		assert_eq(map.cell_at(cell.x, cell.y).content, Content.VOLCANIC_KERNEL_PART)


func test_complete_legacy_wipes_the_lair_or_base_a_part_lands_on() -> void:
	var map := _map(false)
	var lair := MonsterLair.new(MonsterDifficulty.Value.EASY, 20)
	var post := TransitionBase.new(TransitionBaseType.Value.CHEMINEE, "cheminee:0")
	map.set_cell(11, 11, map.cell_at(11, 11).copy_with(
		{"content": Content.RUINS, "lair": lair, "transition_base": post}
	))
	VolcanoFootprint.complete_legacy(map)
	assert_eq(map.cell_at(11, 11).content, Content.VOLCANIC_KERNEL_PART)
	assert_null(map.cell_at(11, 11).lair)
	assert_null(map.cell_at(11, 11).transition_base)


func test_complete_legacy_leaves_a_passage_or_a_wreck_beside_the_kernel_alone() -> void:
	var map := _map(false)
	_put(map, 11, 10, Content.PASSAGE)
	_put(map, 10, 11, Content.WRECK)
	VolcanoFootprint.complete_legacy(map)
	assert_eq(map.cell_at(11, 10).content, Content.PASSAGE)
	assert_eq(map.cell_at(10, 11).content, Content.WRECK)
	assert_eq(map.cell_at(11, 11).content, Content.VOLCANIC_KERNEL_PART)


func test_complete_legacy_leaves_a_complete_footprint_and_maps_without_a_kernel_alone() -> void:
	var map := _map()
	VolcanoFootprint.complete_legacy(map)
	assert_eq(MapSamples.indices_of(map.cells, Content.VOLCANIC_KERNEL_PART).size(), 3)
	var plain := MapSamples.plain_map(5, 5)
	VolcanoFootprint.complete_legacy(plain)
	assert_eq(MapSamples.contents(plain.cells).count(Content.EMPTY), 25)


## Not in the Dart file: a kernel on the last column or row of a map has
## parts off the grid, which are left out; and an anchor is not looked for
## off the grid either.
func test_a_kernel_on_the_edge_of_a_map_is_completed_within_the_map() -> void:
	var map := MapSamples.plain_map(3, 3)
	_put(map, 2, 2, Content.VOLCANIC_KERNEL)
	VolcanoFootprint.complete_legacy(map)
	assert_eq(MapSamples.indices_of(map.cells, Content.VOLCANIC_KERNEL_PART), [])
	_put(map, 0, 0, Content.VOLCANIC_KERNEL_PART)
	assert_null(VolcanoFootprint.anchor_of(map, 0, 0))


func test_reveal_whole_seeing_one_part_reveals_the_anchor_and_the_other_parts() -> void:
	var player := Player.new("p")
	player.add_revealed_cell(3, GridPosition.new(11, 11))
	VolcanoFootprint.reveal_whole(_map(), player, 3)
	var whole: Dictionary[Vector2i, bool] = {
		Vector2i(10, 10): true, Vector2i(11, 10): true, Vector2i(10, 11): true, Vector2i(11, 11): true,
	}
	assert_eq(player.revealed_cells_set_on_level(3), whole)


func test_reveal_whole_a_volcano_out_of_sight_stays_hidden() -> void:
	var player := Player.new("p")
	player.add_revealed_cell(3, GridPosition.new(1, 1))
	VolcanoFootprint.reveal_whole(_map(), player, 3)
	assert_eq(player.revealed_cells_on_level(3).size(), 1)
	# Not in the Dart file: nothing seen on the level, nothing revealed.
	VolcanoFootprint.reveal_whole(_map(), player, 2)
	assert_eq(player.revealed_cells_on_level(2).size(), 0)


func _map(with_parts := true) -> GameMap:
	var map := MapSamples.plain_map(21, 21)
	_put(map, 10, 10, Content.VOLCANIC_KERNEL)
	if with_parts:
		for cell: Vector2i in PARTS:
			_put(map, cell.x, cell.y, Content.VOLCANIC_KERNEL_PART)
	return map


func _put(map: GameMap, x: int, y: int, content: CellContentType.Value) -> void:
	map.set_cell(x, y, map.cell_at(x, y).copy_with({"content": content}))

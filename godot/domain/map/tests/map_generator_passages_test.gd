extends TestCase
## test/domain/map/map_generator_passages_test.dart: the passages a level
## keeps for the posts of the level above.

const Content := CellContentType.Value


func test_reserved_passages_become_passage_cells_with_correct_name() -> void:
	var result := MapGenerator.generate(42, 2, {Vector2i(5, 5): "Faille Alpha"})
	var cell := result.map.cell_at(5, 5)
	assert_eq(cell.content, Content.PASSAGE)
	assert_eq(cell.passage_name, "Faille Alpha")


func test_reserved_passage_at_base_position_is_skipped() -> void:
	var ref := MapGenerator.generate(42)
	var base_key := Vector2i(ref.base_x, ref.base_y)

	var result := MapGenerator.generate(42, 1, {base_key: "Should Skip"})
	var base := result.map.cell_at(base_key.x, base_key.y)
	assert_eq(base.content, Content.EMPTY)
	assert_null(base.passage_name)


func test_no_content_or_transition_base_placed_at_reserved_positions() -> void:
	var reserved: Dictionary[Vector2i, String] = {
		Vector2i(0, 0): "P1",
		Vector2i(19, 0): "P2",
		Vector2i(0, 19): "P3",
		Vector2i(19, 19): "P4",
	}
	var result := MapGenerator.generate(42, 1, reserved)
	var forbidden := [
		Content.MONSTER_LAIR, Content.RESOURCE_BONUS, Content.RUINS, Content.TRANSITION_BASE,
	]
	for pos: Vector2i in reserved:
		var cell := result.map.cell_at(pos.x, pos.y)
		assert_false(forbidden.has(cell.content), "Cell %s has %d" % [pos, cell.content])


## Not in the Dart file: a passage that would open on the volcano of level 3
## is not marked, on its anchor nor on its parts; the others are.
func test_a_passage_onto_the_volcano_is_skipped() -> void:
	var reserved: Dictionary[Vector2i, String] = {
		Vector2i(10, 10): "cheminee:0",
		Vector2i(11, 11): "cheminee:1",
		Vector2i(3, 4): "cheminee:2",
	}
	var map := MapGenerator.generate(42, 3, reserved).map
	assert_eq(map.cell_at(10, 10).content, Content.VOLCANIC_KERNEL)
	assert_null(map.cell_at(10, 10).passage_name)
	assert_eq(map.cell_at(11, 11).content, Content.VOLCANIC_KERNEL_PART)
	assert_null(map.cell_at(11, 11).passage_name)
	assert_eq(map.cell_at(3, 4).content, Content.PASSAGE)
	assert_eq(map.cell_at(3, 4).passage_name, "cheminee:2")


## Not in the Dart file: PassageExtractor gives the posts of a level as the
## passages of the level below, row by row.
func test_the_posts_of_a_level_are_the_passages_of_the_level_below() -> void:
	var above := MapGenerator.generate(42).map
	var passages := PassageExtractor.from(above)
	assert_eq(passages, MapSamples.passages_of(above))
	assert_eq(passages.keys(), MapSamples.passages_of(above).keys())
	assert_eq(passages.size(), 4)
	var names := passages.values()
	names.sort()
	assert_eq(names, ["faille:0", "faille:1", "faille:2", "faille:3"])
	# A post whose cell lost its content, or a content without its post, is none.
	var cell: Vector2i = passages.keys()[0]
	var held := above.cell_at(cell.x, cell.y)
	above.set_cell(cell.x, cell.y, held.copy_with({"content": Content.EMPTY}))
	above.set_cell(0, 0, MapCell.new(TerrainType.Value.PLAIN, Content.TRANSITION_BASE))
	assert_eq(PassageExtractor.from(above).size(), 3)
	assert_false(PassageExtractor.from(above).has(cell))

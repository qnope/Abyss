extends TestCase
## MapWriter writes a generated map as the cases of reference/vectors/
## maps.json do.

const PLAIN := TerrainType.Value.PLAIN
const EASY := MonsterDifficulty.Value.EASY
const Content := CellContentType.Value


func test_a_bare_cell_is_its_content_alone() -> void:
	assert_eq(MapWriter.cell(MapCell.new(PLAIN)), ["empty"])
	assert_eq(MapWriter.cell(MapCell.new(PLAIN, Content.RUINS)), ["ruins"])


func test_a_cell_writes_its_lair_its_post_and_its_passage_without_trailing_nulls() -> void:
	var lair := MonsterLair.new(MonsterDifficulty.Value.HARD, 136, MonsterFamily.Value.HUNTER)
	var post := TransitionBase.new(TransitionBaseType.Value.FAILLE, "faille:0")
	assert_eq(
		MapWriter.cell(MapCell.new(PLAIN, Content.EMPTY, lair)),
		["empty", ["hard", "hunter", 136]],
		"a lair kept under an empty content",
	)
	assert_eq(
		MapWriter.cell(MapCell.new(PLAIN, Content.TRANSITION_BASE, null, null, post)),
		["transitionBase", null, ["faille", "faille:0"]],
	)
	assert_eq(
		MapWriter.cell(MapCell.new(PLAIN, Content.PASSAGE, lair, null, post, "faille:2")),
		["passage", ["hard", "hunter", 136], ["faille", "faille:0"], "faille:2"],
	)
	var generic := MonsterLair.new(EASY, 20)
	var of_generic := MapWriter.cell(MapCell.new(PLAIN, Content.MONSTER_LAIR, generic))
	assert_eq(of_generic, ["monsterLair", ["easy", null, 20]])


func test_a_map_writes_its_size_its_bases_and_the_cells_that_hold_anything() -> void:
	var map := MapSamples.plain_map(3, 2, 7)
	map.set_cell(1, 0, MapCell.new(PLAIN, Content.RUINS))
	map.set_cell(2, 1, MapCell.new(PLAIN, Content.EMPTY, null, null, null, "faille:1"))
	var bases: Array[GridPosition] = [GridPosition.new(0, 1), GridPosition.new(2, 0)]
	assert_eq(MapWriter.write(MapGenerationResult.new(map, 0, 1, bases)), {
		"seed": 7,
		"width": 3,
		"height": 2,
		"baseX": 0,
		"baseY": 1,
		"bases": [[0, 1], [2, 0]],
		"cells": [[1, "ruins"], [5, "empty", null, null, "faille:1"]],
	})


## Dart throws a StateError.
func test_a_cell_holding_more_than_a_vector_writes_logs_an_error() -> void:
	var held: Array[MapCell] = [
		MapCell.new(PLAIN, Content.RUINS, null, "human"),
		MapCell.new(PLAIN, Content.EMPTY, MonsterLair.new(EASY, 2, null, null, 1)),
		MapCell.new(
			PLAIN, Content.EMPTY, null, null,
			TransitionBase.new(TransitionBaseType.Value.FAILLE, "faille:0", "human"),
		),
	]
	for cell: MapCell in held:
		expect_error("MapWriter: a generated cell holds more than a vector writes.")
		MapWriter.cell(cell)

extends VectorTestCase
## reference/vectors/maps.json: whole generated maps, cell by cell, as the
## Dart generators make them, for a spread of seeds, the three levels and
## the map sizes of 1 to 11 players. A cell keeps the lair or the post it
## was given under another content: the vectors write them, and so must the
## port.

var _vectors := VectorFile.new("maps")


func test_world() -> void:
	var cases := _vectors.cases("world")
	assert_eq(cases.size(), 14)
	for case: Dictionary in cases:
		var seed_of_case: int = case["seed"]
		var players: int = case["players"]
		var out: Dictionary = case["out"]
		var world := WorldGenerator.generate(seed_of_case, players)
		assert_eq(world.keys(), [1, 2, 3])
		for level: int in world:
			var label := "seed %d, %d players, level %d" % [seed_of_case, players, level]
			var expected: Dictionary = out[str(level)]
			_assert_map(world[level], expected, label)


func test_level() -> void:
	var cases := _vectors.cases("level")
	assert_eq(cases.size(), 32)
	for case: Dictionary in cases:
		var seed_of_case: int = case["seed"]
		var level: int = case["level"]
		var players: int = case["players"]
		var written: Array = case["passages"]
		var passages: Dictionary[Vector2i, String] = {}
		for passage: Array in written:
			var x: int = passage[0]
			var y: int = passage[1]
			passages[Vector2i(x, y)] = passage[2]
		var result := MapGenerator.generate(seed_of_case, level, passages, players)
		var label := "seed %d, level %d, %d players, %d passages" % [
			seed_of_case, level, players, passages.size()
		]
		var expected: Dictionary = case["out"]
		_assert_map(result, expected, label)


## The map as the case writes it; on a difference, the first cell that
## parts rather than the hundreds of the map.
func _assert_map(result: MapGenerationResult, expected: Dictionary, label: String) -> void:
	var written := MapWriter.write(result)
	var cells: Array = written["cells"]
	var expected_cells: Array = expected["cells"]
	for index: int in mini(cells.size(), expected_cells.size()):
		if VectorValues.encode(cells[index]) != VectorValues.encode(expected_cells[index]):
			assert_same(cells[index], expected_cells[index], "%s, cell %d" % [label, index])
			return
	assert_eq(cells.size(), expected_cells.size(), "%s: cells holding anything" % label)
	written.erase("cells")
	var others := expected.duplicate()
	others.erase("cells")
	assert_same(written, others, label)

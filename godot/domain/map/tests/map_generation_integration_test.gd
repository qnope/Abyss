extends TestCase
## test/domain/map/map_generation_integration_test.dart: everything a
## generated level 1 must hold together.

const EMPTY := CellContentType.Value.EMPTY
const RANGES: Dictionary[MonsterDifficulty.Value, Vector2i] = {
	MonsterDifficulty.Value.EASY: Vector2i(20, 50),
	MonsterDifficulty.Value.MEDIUM: Vector2i(60, 100),
	MonsterDifficulty.Value.HARD: Vector2i(120, 200),
}


func test_seed_reproducibility() -> void:
	var a := MapGenerator.generate(777)
	var b := MapGenerator.generate(777)
	assert_eq([a.base_x, a.base_y], [b.base_x, b.base_y])
	for i: int in 400:
		var of_a := a.map.cells[i]
		var of_b := b.map.cells[i]
		assert_eq([of_a.terrain, of_a.content], [of_b.terrain, of_b.content], "cell %d" % i)
		assert_eq(of_a.lair == null, of_b.lair == null, "cell %d" % i)
		if of_a.lair != null and of_b.lair != null:
			assert_eq(
				[of_a.lair.difficulty, of_a.lair.unit_count],
				[of_b.lair.difficulty, of_b.lair.unit_count],
				"cell %d" % i,
			)


## Dart generates one test per seed.
func test_full_constraints_check_seeds_0_to_9() -> void:
	for seed_of_map: int in 10:
		var result := MapGenerator.generate(seed_of_map)
		var map := result.map
		var label := "seed %d" % seed_of_map

		assert_eq(map.cells.size(), 400, label)
		assert_true(absi(result.base_x - 10) <= 2, label)
		assert_true(absi(result.base_y - 10) <= 2, label)

		# All cells are plain
		for cell: MapCell in map.cells:
			assert_eq(cell.terrain, TerrainType.Value.PLAIN, label)

		# 5-10 monster lairs
		var lairs := MapSamples.indices_of(map.cells, CellContentType.Value.MONSTER_LAIR)
		assert_true(lairs.size() >= 5 and lairs.size() <= 10, "%s: %d" % [label, lairs.size()])

		# Every lair has a stable, in-range unit count
		for index: int in lairs:
			var lair := map.cells[index].lair
			assert_not_null(lair, label)
			var bounds := RANGES[lair.difficulty]
			var fewest := MonsterUnitStats.count_for(lair.family, bounds.x)
			var most := MonsterUnitStats.count_for(lair.family, bounds.y)
			assert_true(lair.unit_count >= fewest and lair.unit_count <= most, label)

		# Base zone empty of content
		for dy: int in range(-2, 3):
			for dx: int in range(-2, 3):
				var x := result.base_x + dx
				var y := result.base_y + dy
				assert_eq(map.cell_at(x, y).content, EMPTY, "%s (%d,%d)" % [label, x, y])

extends TestCase
## test/domain/map/lair_builder_test.dart: the lair of a cell, its size from
## the dice of the map and its family from the cell.

const EASY := MonsterDifficulty.Value.EASY


func test_the_family_of_a_cell_depends_only_on_the_seed_and_the_cell() -> void:
	assert_eq(LairBuilder.family_for(7, 42, 2), LairBuilder.family_for(7, 42, 2))
	var families: Dictionary[MonsterFamily.Value, bool] = {}
	for cell: int in 60:
		families[LairBuilder.family_for(7, cell, 2)] = true
	assert_eq(families.size(), MonsterFamily.available_at(2).size())
	for family: MonsterFamily.Value in MonsterFamily.available_at(2):
		assert_has(families, family)


func test_level_1_lairs_are_never_colossi() -> void:
	for cell: int in 200:
		assert_ne(LairBuilder.family_for(3, cell, 1), MonsterFamily.Value.COLOSSUS)


func test_picking_a_family_does_not_consume_the_map_dice() -> void:
	var a := DartRandom.new(5)
	var b := DartRandom.new(5)
	LairBuilder.build(EASY, a, 1, 3)
	LairBuilder.build(EASY, b, 99, 80)
	assert_eq(a.next_int(1000), b.next_int(1000))


## Not in the Dart file: the size of a lair of each difficulty, between the
## counts its family gives for the fewest and the most generic monsters.
func test_a_lair_is_sized_by_its_difficulty_and_its_family() -> void:
	var ranges: Dictionary[MonsterDifficulty.Value, Vector2i] = {
		EASY: Vector2i(20, 50),
		MonsterDifficulty.Value.MEDIUM: Vector2i(60, 100),
		MonsterDifficulty.Value.HARD: Vector2i(120, 200),
	}
	for difficulty: MonsterDifficulty.Value in ranges:
		var fewest := ranges[difficulty].x
		var most := ranges[difficulty].y
		for seed_of_lair: int in 40:
			var lair := LairBuilder.build(difficulty, DartRandom.new(seed_of_lair), 7, seed_of_lair)
			assert_eq(lair.difficulty, difficulty)
			assert_null(lair.second_family)
			assert_true(lair.unit_count >= MonsterUnitStats.count_for(lair.family, fewest))
			assert_true(lair.unit_count <= MonsterUnitStats.count_for(lair.family, most))

extends TestCase
## test/domain/map/monster_difficulty_test.dart: how hard a lair is.

const Difficulty := MonsterDifficulty.Value


func test_monster_difficulty_has_all_3_values() -> void:
	assert_eq(Difficulty.size(), 3)
	assert_has(Difficulty.values(), Difficulty.EASY)
	assert_has(Difficulty.values(), Difficulty.MEDIUM)
	assert_has(Difficulty.values(), Difficulty.HARD)


func test_monster_difficulty_values_have_correct_indices() -> void:
	assert_eq(Difficulty.EASY, 0)
	assert_eq(Difficulty.MEDIUM, 1)
	assert_eq(Difficulty.HARD, 2)


## Not in the Dart file: the names the snapshots and the vectors write.
func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(DartEnum.names(Difficulty), PackedStringArray(["easy", "medium", "hard"]))

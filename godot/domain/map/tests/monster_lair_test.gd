extends TestCase
## test/domain/map/monster_lair_test.dart: a group of monsters of one level.

const EASY := MonsterDifficulty.Value.EASY
const MEDIUM := MonsterDifficulty.Value.MEDIUM
const HARD := MonsterDifficulty.Value.HARD
const SWARM := MonsterFamily.Value.SWARM
const HUNTER := MonsterFamily.Value.HUNTER


func test_monster_lair_constructor_round_trips_fields() -> void:
	var lair := MonsterLair.new(MEDIUM, 75)
	assert_eq(lair.difficulty, MEDIUM)
	assert_eq(lair.unit_count, 75)


func test_monster_lair_level_returns_1_for_easy() -> void:
	assert_eq(MonsterLair.new(EASY, 20).level(), 1)


func test_monster_lair_level_returns_2_for_medium() -> void:
	assert_eq(MonsterLair.new(MEDIUM, 60).level(), 2)


func test_monster_lair_level_returns_3_for_hard() -> void:
	assert_eq(MonsterLair.new(HARD, 150).level(), 3)


## Not in the Dart file: the defaults of the constructor.
func test_a_lair_has_no_family_and_no_second_group_unless_told() -> void:
	var lair := MonsterLair.new(EASY, 20)
	assert_null(lair.family)
	assert_null(lair.second_family)
	assert_eq(lair.second_count, 0)


## Not in the Dart file: `groups` and `totalCount`, which the tests of the
## raids and of the fights hold in Dart.
func test_groups_lists_each_family_with_its_count_empty_ones_left_out() -> void:
	var wave := MonsterLair.new(HARD, 30, SWARM, HUNTER, 12)
	assert_eq(wave.groups(), {SWARM: 30, HUNTER: 12})
	assert_eq(wave.groups().keys(), [SWARM, HUNTER])
	assert_eq(wave.total_count(), 42)
	var generic := MonsterLair.new(EASY, 25)
	assert_eq(generic.groups(), {null: 25})
	assert_eq(generic.total_count(), 25)
	assert_eq(MonsterLair.new(EASY, 0, SWARM, HUNTER, 4).groups(), {HUNTER: 4})
	assert_eq(MonsterLair.new(EASY, 0, SWARM, HUNTER, 0).total_count(), 0)
	assert_eq(MonsterLair.new(EASY, 5, SWARM, null, 9).groups(), {SWARM: 5})


## Not in the Dart file: a map literal that names a key twice keeps the
## place of the first and the value of the last.
func test_groups_of_twice_the_same_family_keeps_the_second_count() -> void:
	var twice := MonsterLair.new(MEDIUM, 30, SWARM, SWARM, 12)
	assert_eq(twice.groups(), {SWARM: 12})
	assert_eq(twice.total_count(), 12)

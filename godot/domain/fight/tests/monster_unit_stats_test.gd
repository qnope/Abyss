extends VectorTestCase
## test/domain/fight/monster_unit_stats_test.dart: the stats of one monster,
## by family and level; and the sections monsters and monsterLevels of
## reference/vectors/fight_rules.json, as the Dart rules answer.

const Lair := MonsterDifficulty.Value

var _vectors := VectorFile.new("fight_rules")


func test_for_level_level_1_returns_hp_10_atk_3_def_1() -> void:
	var stats := MonsterUnitStats.for_level(1)
	assert_eq([stats.hp, stats.atk, stats.def], [10, 3, 1])


func test_for_level_level_2_returns_hp_20_atk_5_def_2() -> void:
	var stats := MonsterUnitStats.for_level(2)
	assert_eq([stats.hp, stats.atk, stats.def], [20, 5, 2])


func test_for_level_level_3_returns_hp_35_atk_8_def_3() -> void:
	var stats := MonsterUnitStats.for_level(3)
	assert_eq([stats.hp, stats.atk, stats.def], [35, 8, 3])


## Dart throws an ArgumentError: the port logs an error and gives no stats.
func test_for_level_level_0_throws_argument_error() -> void:
	expect_error("MonsterUnitStats.of: the level 0 is not 1, 2 or 3")
	assert_null(MonsterUnitStats.for_level(0))


func test_for_level_level_4_throws_argument_error() -> void:
	expect_error("MonsterUnitStats.of: the level 4 is not 1, 2 or 3")
	assert_null(MonsterUnitStats.of(MonsterFamily.Value.SWARM, 4))


func test_level_for_easy_maps_to_level_1() -> void:
	assert_eq(MonsterUnitStats.level_for(Lair.EASY), 1)


func test_level_for_medium_maps_to_level_2() -> void:
	assert_eq(MonsterUnitStats.level_for(Lair.MEDIUM), 2)


func test_level_for_hard_maps_to_level_3() -> void:
	assert_eq(MonsterUnitStats.level_for(Lair.HARD), 3)


func test_monsters() -> void:
	var cases := _vectors.cases("monsters")
	assert_eq(cases.size(), 6, "the generic monsters and the five families")
	for case: Dictionary in cases:
		var family: Variant = null
		var boss := false
		if case["family"] != null:
			var known := VectorInputs.value(MonsterFamily.Value, case["family"]) as MonsterFamily.Value
			family = known
			boss = MonsterFamily.is_boss(known)
		var stats := []
		var type_keys := []
		for level: int in [1, 2, 3]:
			var of_level := MonsterUnitStats.of(family, level)
			stats.append([of_level.hp, of_level.atk, of_level.def])
			type_keys.append(MonsterFamily.type_key_of(family, level))
		var counts: Array = case["counts"]
		var out := {
			"stats": stats,
			"typeKeys": type_keys,
			"isBoss": boss,
			"countPercent": MonsterUnitStats.count_percent(family),
			"countFor": counts.map(
				func(count: int) -> int: return MonsterUnitStats.count_for(family, count)
			),
		}
		assert_same(out, case["out"], str(case["family"]))


func test_monster_levels() -> void:
	var cases := _vectors.cases("monsterLevels")
	assert_eq(cases.size(), 3)
	for case: Dictionary in cases:
		var difficulty := VectorInputs.value(Lair, case["difficulty"]) as Lair
		var level := MonsterUnitStats.level_for(difficulty)
		var families := VectorInputs.names(MonsterFamily.Value, MonsterFamily.available_at(level))
		assert_same({"level": level, "families": families}, case["out"], str(case))

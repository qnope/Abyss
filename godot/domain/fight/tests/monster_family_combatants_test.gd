extends TestCase
## test/domain/fight/monster_family_combatants_test.dart: the monsters of a
## family as they fight. Its fourth test, a family read back from its key,
## is in map/tests/monster_family_test.gd, ported with the map.

const SWARM := MonsterFamily.Value.SWARM
const HUNTER := MonsterFamily.Value.HUNTER


func test_a_family_lair_fights_with_its_family_stats_and_key() -> void:
	var lair := MonsterLair.new(MonsterDifficulty.Value.MEDIUM, 3, MonsterFamily.Value.ARMOURED)
	var combatants := CombatantBuilder.monster_combatants_from(lair)
	var stats := MonsterUnitStats.of(MonsterFamily.Value.ARMOURED, 2)
	assert_eq(combatants.size(), 3)
	for c: Combatant in combatants:
		assert_eq(c.type_key, "armouredL2")
		assert_eq(c.def, stats.def)
		assert_false(c.is_boss)


func test_a_raid_wave_fields_both_of_its_families() -> void:
	var wave := MonsterLair.new(MonsterDifficulty.Value.EASY, 4, SWARM, HUNTER, 2)
	var keys := CombatantBuilder.monster_combatants_from(wave).map(
		func(c: Combatant) -> String: return c.type_key
	)
	assert_eq(keys.count("swarmL1"), 4)
	assert_eq(keys.count("hunterL1"), 2)
	assert_eq(wave.total_count(), 6)


func test_colossi_are_bosses() -> void:
	var lair := MonsterLair.new(MonsterDifficulty.Value.HARD, 2, MonsterFamily.Value.COLOSSUS)
	var combatants := CombatantBuilder.monster_combatants_from(lair)
	assert_true(combatants.all(func(c: Combatant) -> bool: return c.is_boss))


func test_family_sizes_stand_for_the_same_generic_lair() -> void:
	assert_eq(MonsterUnitStats.count_for(SWARM, 20), 60)
	assert_eq(MonsterUnitStats.count_for(MonsterFamily.Value.ARMOURED, 20), 14)
	assert_eq(MonsterUnitStats.count_for(HUNTER, 20), 16)
	assert_eq(MonsterUnitStats.count_for(MonsterFamily.Value.COLOSSUS, 20), 3)
	assert_eq(MonsterUnitStats.count_for(MonsterFamily.Value.COLOSSUS, 1), 1)
	assert_eq(MonsterUnitStats.count_for(MonsterFamily.Value.KRAKEN, 20), 2)
	assert_eq(MonsterUnitStats.count_for(MonsterFamily.Value.KRAKEN, 5), 1)
	assert_eq(MonsterUnitStats.count_for(null, 20), 20)


## Not in the Dart file: the families come in the order of the groups, the
## swarm first, then the hunters.
func test_fields_the_groups_in_their_order() -> void:
	var wave := MonsterLair.new(MonsterDifficulty.Value.EASY, 1, SWARM, HUNTER, 1)
	var combatants := CombatantBuilder.monster_combatants_from(wave)
	assert_eq([combatants[0].type_key, combatants[1].type_key], ["swarmL1", "hunterL1"])

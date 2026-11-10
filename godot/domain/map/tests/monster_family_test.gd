extends TestCase
## The families of monsters. Dart has no test file for monster_family.dart:
## the first test is 'a family is read back from its combatant key' of
## test/domain/fight/monster_family_combatants_test.dart, the others hold
## what the tests of the lairs, the raids and the fights check on the way.

const SWARM := MonsterFamily.Value.SWARM
const ARMOURED := MonsterFamily.Value.ARMOURED
const HUNTER := MonsterFamily.Value.HUNTER
const COLOSSUS := MonsterFamily.Value.COLOSSUS
const KRAKEN := MonsterFamily.Value.KRAKEN


func test_a_family_is_read_back_from_its_combatant_key() -> void:
	for family: MonsterFamily.Value in MonsterFamily.Value.values():
		assert_eq(MonsterFamily.of_type_key(MonsterFamily.type_key_of(family, 3)), family)
	assert_null(MonsterFamily.of_type_key("monsterL1"))
	assert_null(MonsterFamily.of_type_key("harpoonist"))


func test_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(
		DartEnum.names(MonsterFamily.Value),
		PackedStringArray(["swarm", "armoured", "hunter", "colossus", "kraken"])
	)


func test_writes_the_key_of_a_monster_from_its_family_and_its_level() -> void:
	assert_eq(MonsterFamily.type_key_of(ARMOURED, 2), "armouredL2")
	assert_eq(MonsterFamily.type_key_of(KRAKEN, 10), "krakenL10")
	assert_eq(MonsterFamily.type_key_of(null, 1), "monsterL1")


func test_reads_no_family_from_a_key_without_one() -> void:
	assert_null(MonsterFamily.of_type_key(""))
	assert_null(MonsterFamily.of_type_key("L3"))
	assert_null(MonsterFamily.of_type_key("rampart"))
	assert_null(MonsterFamily.of_type_key("HUNTERL2"))
	assert_eq(MonsterFamily.of_type_key("hunterL"), HUNTER)


func test_colossi_only_show_up_from_level_2_and_the_kraken_never() -> void:
	assert_eq(MonsterFamily.available_at(1), [SWARM, ARMOURED, HUNTER])
	assert_eq(MonsterFamily.available_at(2), [SWARM, ARMOURED, HUNTER, COLOSSUS])
	assert_eq(MonsterFamily.available_at(3), [SWARM, ARMOURED, HUNTER, COLOSSUS])


func test_colossi_and_krakens_are_bosses() -> void:
	assert_false(MonsterFamily.is_boss(SWARM))
	assert_false(MonsterFamily.is_boss(ARMOURED))
	assert_false(MonsterFamily.is_boss(HUNTER))
	assert_true(MonsterFamily.is_boss(COLOSSUS))
	assert_true(MonsterFamily.is_boss(KRAKEN))

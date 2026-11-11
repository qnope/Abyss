extends TextsTestCase
## test/presentation/extensions/monster_lair_extensions_test.dart, for the
## texts.

const Family := MonsterFamily.Value
const Difficulty := MonsterDifficulty.Value


func test_names_a_wave_of_one_family() -> void:
	var lair := MonsterLair.new(Difficulty.EASY, 40, Family.SWARM)
	assert_eq(MonsterLairTexts.wave_label(lair), "40 Dents-de-verre niv. 1")


func test_names_a_wave_of_two_families_joined_by_and() -> void:
	var lair := MonsterLair.new(Difficulty.MEDIUM, 40, Family.SWARM, Family.HUNTER, 12)
	assert_eq(MonsterLairTexts.wave_label(lair), "40 Dents-de-verre et 12 Calmars-chasseurs niv. 2")
	TranslationServer.set_locale("en")
	assert_eq(MonsterLairTexts.wave_label(lair), "40 Glassfangs and 12 Hunter Squids lv. 2")


func test_names_a_wave_of_generic_monsters() -> void:
	var lair := MonsterLair.new(Difficulty.HARD, 5)
	assert_eq(MonsterLairTexts.wave_label(lair), "5 monstres niv. 3")


func test_tells_what_a_wave_is_weak_against() -> void:
	var lair := MonsterLair.new(Difficulty.EASY, 4, Family.SWARM, Family.HUNTER, 2)
	assert_eq(MonsterLairTexts.weakness_label(lair), "Faibles contre : Harponneurs, Gardiens")


func test_tells_no_weakness_for_generic_monsters() -> void:
	assert_null(MonsterLairTexts.weakness_label(MonsterLair.new(Difficulty.EASY, 4)))


func test_the_wording_is_in_every_language() -> void:
	assert_translated(&"monsterLairGroupsAnd")
	assert_translated(&"monsterLairWave")
	assert_translated(&"monsterLairWeakAgainst")

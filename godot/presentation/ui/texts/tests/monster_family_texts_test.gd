extends TextsTestCase
## test/presentation/extensions/monster_family_extensions_test.dart, for the
## texts. A null family is the generic monster.

const Family := MonsterFamily.Value


func test_names_a_family_and_the_generic_monsters() -> void:
	assert_eq(MonsterFamilyTexts.label(null), "Rôdeurs")
	assert_eq(MonsterFamilyTexts.label(Family.SWARM), "Nuée")
	TranslationServer.set_locale("en")
	assert_eq(MonsterFamilyTexts.label(null), "Prowlers")


func test_counts_the_monsters_of_a_family() -> void:
	assert_eq(MonsterFamilyTexts.monsters(Family.ARMOURED, 12), "12 Isopodes cuirassés")
	assert_eq(MonsterFamilyTexts.monsters(Family.ARMOURED, 1), "1 Isopode cuirassé")
	assert_eq(MonsterFamilyTexts.monsters(null, 2), "2 monstres")


func test_the_rule_of_a_family_and_none_for_the_generic_monsters() -> void:
	assert_eq(MonsterFamilyTexts.rule(Family.SWARM), "Essaim : un coup de Harponneur touche deux poissons.")
	assert_null(MonsterFamilyTexts.rule(null))


func test_the_weakness_of_a_family_and_the_kraken_s_is_the_colossus() -> void:
	assert_eq(MonsterFamilyTexts.weakness(Family.HUNTER), "Gardiens")
	assert_eq(MonsterFamilyTexts.weakness(Family.COLOSSUS), "Briseurs de dôme")
	assert_eq(MonsterFamilyTexts.weakness(Family.KRAKEN), "Briseurs de dôme")
	assert_null(MonsterFamilyTexts.weakness(null))


func test_every_family_has_its_texts_in_every_language() -> void:
	for suffix: String in ["Label", "Count", "Rule"]:
		assert_every_value_translated(Family, func(family: int) -> String:
			return TextKeys.of("monsterFamily", Family, family, suffix))
	for suffix: String in ["Label", "Count"]:
		assert_translated(StringName("monsterFamilyGeneric" + suffix))
	# The kraken answers as the colossus does.
	assert_every_value_translated(Family, func(family: int) -> String:
		var answered := Family.COLOSSUS if family == Family.KRAKEN else family
		return TextKeys.of("monsterFamily", Family, answered, "Weakness"))

extends TextsTestCase
## test/presentation/extensions/unit_army_texts_test.dart.

const Type := UnitType.Value


func test_names_one_unit_in_the_singular() -> void:
	assert_eq(UnitArmyTexts.plaque_name(Type.HARPOONIST, 1), "Harponneur")
	assert_eq(UnitArmyTexts.plaque_name(Type.ABYSS_ADMIRAL, 1), "Amiral des Abysses")


func test_names_an_empty_squad_or_several_units_in_the_plural() -> void:
	assert_eq(UnitArmyTexts.plaque_name(Type.HARPOONIST, 22), "Harponneurs")
	assert_eq(UnitArmyTexts.plaque_name(Type.DOME_BREAKER, 0), "Briseurs")
	assert_eq(UnitArmyTexts.plaque_name(Type.ABYSS_ADMIRAL, 3), "Amiraux des abysses")


func test_names_a_locked_squad_in_the_singular() -> void:
	assert_eq(UnitArmyTexts.plaque_name(Type.GUARDIAN, 0, true), "Gardien")


func test_names_the_squads_in_english_and_spanish() -> void:
	TranslationServer.set_locale("en")
	assert_eq(UnitArmyTexts.plaque_name(Type.HARPOONIST, 1500), "Harpooners")
	TranslationServer.set_locale("es")
	assert_eq(UnitArmyTexts.plaque_name(Type.SCOUT, 4), "Exploradores")
	assert_eq(UnitArmyTexts.plaque_name(Type.GUARDIAN, 1), "Guardián")


func test_says_how_many_units_a_squad_holds_and_whether_it_recruits() -> void:
	assert_eq(UnitArmyTexts.army_label(Type.HARPOONIST, 22, false, true), "Harponneurs, 22 unités, recrutable")
	assert_eq(UnitArmyTexts.army_label(Type.SCOUT, 1, false, false), "Éclaireur, 1 unité")


func test_says_which_barracks_level_a_locked_squad_waits_for() -> void:
	assert_eq(UnitArmyTexts.army_label(Type.GUARDIAN, 0, true, true), "Gardien, verrouillé, Caserne niveau 3")
	TranslationServer.set_locale("en")
	assert_eq(UnitArmyTexts.army_label(Type.SABOTEUR, 0, true, false), "Saboteur, locked, Barracks level 5")


func test_reads_in_spanish() -> void:
	TranslationServer.set_locale("es")
	assert_eq(UnitArmyTexts.army_label(Type.HARPOONIST, 2, false, true), "Arponeros, 2 unidades, reclutable")


func test_the_lock_pill_names_the_barracks_level() -> void:
	assert_eq(UnitArmyTexts.lock_pill(Type.GUARDIAN), "Caserne niv. 3")
	TranslationServer.set_locale("en")
	assert_eq(UnitArmyTexts.lock_pill(Type.SABOTEUR), "Barracks lv. 5")

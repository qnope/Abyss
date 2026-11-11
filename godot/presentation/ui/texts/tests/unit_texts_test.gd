extends TextsTestCase
## test/presentation/extensions/unit_type_extensions_test.dart, for the texts.

const Type := UnitType.Value


func test_names_a_unit_and_its_role() -> void:
	assert_eq(UnitTexts.display_name(Type.DOME_BREAKER), "Briseur")
	assert_eq(UnitTexts.role(Type.SCOUT), "Éclaireur")
	assert_eq(UnitTexts.role_effect(Type.SCOUT), "Fuit au lieu de mourir : revient toujours blessé.")


func test_counts_the_units_of_a_type_in_the_plural_of_the_language() -> void:
	assert_eq(UnitTexts.units(Type.SCOUT, 3), "3 éclaireurs")
	assert_eq(UnitTexts.units(Type.SCOUT, 1), "1 éclaireur")
	assert_eq(UnitTexts.units(Type.SCOUT, 0), "0 éclaireur")
	TranslationServer.set_locale("en")
	assert_eq(UnitTexts.units(Type.SCOUT, 0), "0 scouts")


func test_every_unit_has_its_four_texts_in_every_language() -> void:
	for suffix: String in ["Name", "Count", "Role", "RoleEffect"]:
		assert_every_value_translated(Type, func(type: int) -> String:
			return TextKeys.of("unit", Type, type, suffix))

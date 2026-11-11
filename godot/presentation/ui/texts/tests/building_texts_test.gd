extends TextsTestCase
## test/presentation/extensions/building_type_extensions_test.dart, for the texts.

const Type := BuildingType.Value


func test_names_a_building() -> void:
	assert_eq(BuildingTexts.display_name(Type.HEADQUARTERS), "Quartier Général")
	assert_eq(BuildingTexts.display_name(Type.CORAL_CITADEL), "Citadelle corallienne")
	TranslationServer.set_locale("en")
	assert_eq(BuildingTexts.display_name(Type.ALGAE_FARM), "Algae Farm")


func test_the_headquarters_tells_the_income_it_makes() -> void:
	assert_has(BuildingTexts.description(Type.HEADQUARTERS), "il fournit 15 corail et 10 minerai par tour.")
	TranslationServer.set_locale("en")
	assert_has(BuildingTexts.description(Type.HEADQUARTERS), "15 coral and 10 ore")


func test_describes_the_other_buildings() -> void:
	assert_eq(BuildingTexts.description(Type.ALGAE_FARM), "Cultive des algues pour nourrir votre colonie sous-marine.")


func test_every_building_has_a_name_and_a_description_in_every_language() -> void:
	assert_every_value_translated(Type, func(type: int) -> String:
		return TextKeys.of("building", Type, type, "Name"))
	assert_every_value_translated(Type, func(type: int) -> String:
		return TextKeys.of("building", Type, type, "Description"))

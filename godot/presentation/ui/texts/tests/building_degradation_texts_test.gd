extends TextsTestCase
## What a degraded building suffers, in words.

const Type := BuildingType.Value


func test_the_producers_make_half() -> void:
	for type: BuildingType.Value in [Type.HEADQUARTERS, Type.ALGAE_FARM, Type.CORAL_MINE, Type.ORE_EXTRACTOR]:
		assert_eq(BuildingDegradationTexts.degraded_effect(type), "Produit 50 % de ses ressources")


func test_each_other_building_suffers_in_its_own_way() -> void:
	assert_eq(BuildingDegradationTexts.degraded_effect(Type.SOLAR_PANEL), "Produit 50 % de son énergie")
	assert_eq(BuildingDegradationTexts.degraded_effect(Type.LABORATORY), "Les recherches ont la moitié de leur effet")
	assert_eq(BuildingDegradationTexts.degraded_effect(Type.BARRACKS), "Les unités coûtent deux fois plus cher")
	assert_eq(BuildingDegradationTexts.degraded_effect(Type.CORAL_CITADEL), "Le rempart a la moitié de sa force")


func test_the_buildings_of_the_depths_are_unusable() -> void:
	for type: BuildingType.Value in [Type.DESCENT_MODULE, Type.PRESSURE_CAPSULE, Type.VOLCANIC_KERNEL]:
		assert_eq(BuildingDegradationTexts.degraded_effect(type), "Inutilisable : ni descente, ni garnison, ni victoire")


func test_follows_the_language() -> void:
	TranslationServer.set_locale("en")
	assert_eq(BuildingDegradationTexts.degraded_effect(Type.BARRACKS), "Units cost twice as much")


func test_every_building_has_an_effect() -> void:
	for type: BuildingType.Value in Type.values():
		assert_ne(BuildingDegradationTexts.degraded_effect(type), "", str(type))
	for key: StringName in [&"buildingDegradedProduction", &"buildingDegradedSolar",
		&"buildingDegradedLaboratory", &"buildingDegradedBarracks", &"buildingDegradedCitadel",
		&"buildingDegradedUnusable", &"buildingDegraded", &"buildingDegradedReason"]:
		assert_translated(key)

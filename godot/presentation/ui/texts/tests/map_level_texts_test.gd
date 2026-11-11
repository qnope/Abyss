extends TextsTestCase
## lib/presentation/widgets/map/map_level_info.dart: the depths' names.


func test_names_the_three_depths_in_every_language() -> void:
	assert_eq(MapLevelTexts.LEVELS, [1, 2, 3] as Array[int])
	assert_eq(MapLevelTexts.name_of(1), "Surface")
	assert_eq(MapLevelTexts.name_of(2), "Profondeurs")
	assert_eq(MapLevelTexts.name_of(3), "Noyau")
	TranslationServer.set_locale("en")
	assert_eq(MapLevelTexts.name_of(2), "Depths")


func test_every_depth_has_a_name_in_every_language() -> void:
	for key: StringName in [&"mapLevelSurface", &"mapLevelDepths", &"mapLevelCore"]:
		assert_translated(key)

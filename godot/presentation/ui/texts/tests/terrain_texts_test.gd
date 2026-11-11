extends TextsTestCase
## test/presentation/extensions/terrain_type_extensions_test.dart, for the texts.


func test_names_the_plain_in_every_language() -> void:
	assert_eq(TerrainTexts.label(TerrainType.Value.PLAIN), "Plaine")
	TranslationServer.set_locale("en")
	assert_eq(TerrainTexts.label(TerrainType.Value.PLAIN), "Plain")


func test_every_terrain_has_a_name_in_every_language() -> void:
	assert_eq(TerrainType.Value.size(), 1)
	assert_translated(&"terrainPlain")

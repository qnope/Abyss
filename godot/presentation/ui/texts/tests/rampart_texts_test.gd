extends TextsTestCase
## test/presentation/extensions/rampart_texts_test.dart.


func test_the_citadel_rampart_is_none_without_a_citadel() -> void:
	assert_eq(RampartTexts.coral(0), "aucun")
	TranslationServer.set_locale("en")
	assert_eq(RampartTexts.coral(0), "none")
	TranslationServer.set_locale("es")
	assert_eq(RampartTexts.coral(0), "ninguna")


func test_the_citadel_rampart_tells_its_hp_and_def() -> void:
	assert_eq(RampartTexts.coral(3), "120 PV, DEF 7")
	TranslationServer.set_locale("en")
	assert_eq(RampartTexts.coral(3), "120 HP, DEF 7")
	TranslationServer.set_locale("es")
	assert_eq(RampartTexts.coral(3), "120 PV, DEF 7")


func test_the_magma_rampart_tells_its_hp_atk_and_def() -> void:
	assert_eq(RampartTexts.magma(5), "200 PV, ATK 14, DEF 8")
	TranslationServer.set_locale("en")
	assert_eq(RampartTexts.magma(5), "200 HP, ATK 14, DEF 8")

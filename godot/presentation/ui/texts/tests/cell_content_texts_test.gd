extends TextsTestCase
## test/presentation/extensions/cell_content_type_extensions_test.dart.

const Content := CellContentType.Value


func test_names_what_a_cell_holds() -> void:
	assert_eq(CellContentTexts.label(Content.EMPTY), "Vide")
	assert_eq(CellContentTexts.label(Content.RUINS), "Ruines")
	assert_eq(CellContentTexts.label(Content.WRECK), "Épave")
	assert_eq(CellContentTexts.label(Content.TRANSITION_BASE), "Faille Abyssale")
	assert_eq(CellContentTexts.label(Content.VOLCANIC_KERNEL), "Noyau Volcanique")
	assert_eq(CellContentTexts.label(Content.VOLCANIC_KERNEL_PART), "Noyau Volcanique")


func test_follows_the_language() -> void:
	TranslationServer.set_locale("en")
	assert_eq(CellContentTexts.label(Content.RUINS), "Ruins")
	assert_eq(CellContentTexts.label(Content.WRECK), "Wreck")


func test_every_content_has_a_name_in_every_language() -> void:
	for content: Content in Content.values():
		for locale in LANGUAGES:
			TranslationServer.set_locale(locale)
			assert_false(CellContentTexts.label(content).is_empty(), "%s in %s" % [content, locale])

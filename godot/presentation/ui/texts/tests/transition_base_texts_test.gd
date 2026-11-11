extends TextsTestCase
## test/presentation/extensions/transition_base_type_extensions_test.dart.

const Type := TransitionBaseType.Value


func test_the_faille_is_the_passage_to_the_depths() -> void:
	assert_eq(TransitionBaseTexts.display_name(Type.FAILLE), "Faille Abyssale")
	assert_eq(TransitionBaseTexts.description(Type.FAILLE), "Passage vers les profondeurs")
	TranslationServer.set_locale("en")
	assert_eq(TransitionBaseTexts.display_name(Type.FAILLE), "Abyssal Rift")
	assert_eq(TransitionBaseTexts.description(Type.FAILLE), "Passage to the depths")
	TranslationServer.set_locale("es")
	assert_eq(TransitionBaseTexts.display_name(Type.FAILLE), "Falla abisal")


func test_the_cheminee_is_the_passage_to_the_core() -> void:
	assert_eq(TransitionBaseTexts.display_name(Type.CHEMINEE), "Cheminée du Noyau")
	TranslationServer.set_locale("en")
	assert_eq(TransitionBaseTexts.display_name(Type.CHEMINEE), "Core Vent")
	TranslationServer.set_locale("es")
	assert_eq(TransitionBaseTexts.description(Type.CHEMINEE), "Paso hacia el núcleo")


func test_every_base_type_has_a_name_and_a_description_in_every_language() -> void:
	assert_every_value_translated(Type, func(type: int) -> String:
		return TextKeys.of("transitionBase", Type, type, "Name"))
	assert_every_value_translated(Type, func(type: int) -> String:
		return TextKeys.of("transitionBase", Type, type, "Description"))

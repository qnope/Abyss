extends TextsTestCase
## test/presentation/extensions/random_event_type_extensions_test.dart.

const Type := RandomEventType.Value


func test_every_event_has_a_short_french_name() -> void:
	assert_eq(RandomEventTexts.label(Type.WARM_CURRENT), "Courant chaud")
	assert_eq(RandomEventTexts.label(Type.WRECK), "Épave")
	assert_eq(RandomEventTexts.label(Type.PREDATORS), "Banc de prédateurs")
	assert_eq(RandomEventTexts.label(Type.STORM), "Tempête")
	assert_eq(RandomEventTexts.label(Type.SURVIVORS), "Survivants")
	assert_eq(RandomEventTexts.label(Type.CARAVAN), "Caravane de tortues")
	assert_eq(RandomEventTexts.label(Type.COLD_CURRENT), "Courant froid")


func test_every_event_has_a_short_name_in_english_and_spanish() -> void:
	TranslationServer.set_locale("en")
	assert_eq(RandomEventTexts.label(Type.PREDATORS), "Predator Shoal")
	assert_eq(RandomEventTexts.label(Type.CARAVAN), "Turtle Caravan")
	TranslationServer.set_locale("es")
	assert_eq(RandomEventTexts.label(Type.WARM_CURRENT), "Corriente cálida")
	assert_eq(RandomEventTexts.label(Type.SURVIVORS), "Supervivientes")


func test_every_event_is_translated_in_every_language() -> void:
	assert_every_value_translated(Type, func(type: int) -> String:
		return TextKeys.of("randomEvent", Type, type, "Label"))


func test_every_event_has_its_own_illustration_among_the_event_icons() -> void:
	assert_eq(RandomEventTexts.illustration(Type.WARM_CURRENT), "res://assets/icons/events/warm_current.svg")
	assert_eq(RandomEventTexts.illustration(Type.COLD_CURRENT), "res://assets/icons/events/cold_current.svg")
	var paths := {}
	for type: Type in Type.values():
		var path := RandomEventTexts.illustration(type)
		paths[path] = true
		assert_true(path.begins_with("res://assets/icons/events/"), path)
		assert_true(ResourceLoader.exists(path), path)
	assert_eq(paths.size(), Type.size())

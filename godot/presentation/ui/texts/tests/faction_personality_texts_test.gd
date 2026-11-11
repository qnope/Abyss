extends TextsTestCase
## test/presentation/extensions/faction_personality_extensions_test.dart.

const Kind := FactionPersonality.Value


func test_tells_where_a_faction_comes_from() -> void:
	assert_eq(FactionPersonalityTexts.origin(Kind.SILENCE_MONKS),
		"Un monastère flottant : ils ont compris les premiers que les abysses écoutent.")
	TranslationServer.set_locale("en")
	assert_true(FactionPersonalityTexts.origin(Kind.SILENCE_MONKS).begins_with("A floating monastery"))


func test_every_faction_has_its_origin_in_every_language() -> void:
	assert_every_value_translated(Kind, func(personality: int) -> String:
		return TextKeys.of("factionOrigin", Kind, personality))

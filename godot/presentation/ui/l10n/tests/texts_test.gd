extends TextsTestCase
## Texts against the .po files, and every plural and select of the ARB
## files against what Flutter wrote (expected_texts.json, README.md).

const EXPECTED := "res://presentation/ui/l10n/tests/expected_texts.json"


func test_writes_a_message_in_the_language_on() -> void:
	TranslationServer.set_locale("fr")
	assert_eq(Texts.t(&"unitScoutCount", {"count": 3}), "3 éclaireurs")
	TranslationServer.set_locale("en")
	assert_eq(Texts.t(&"unitScoutCount", {"count": 1}), "1 scout")
	TranslationServer.set_locale("es")
	assert_eq(Texts.t(&"unitScoutCount", {"count": 0}), "0 exploradores")


func test_a_message_without_argument_is_its_translation() -> void:
	TranslationServer.set_locale("fr")
	assert_eq(Texts.t(&"settingsLanguageAutomatic"), "Automatique")
	TranslationServer.set_locale("en")
	assert_eq(Texts.t(&"settingsLanguageAutomatic"), "Automatic")


func test_an_unknown_key_is_an_error_and_shows_the_key() -> void:
	expect_error("no translation for \"noSuchKey\"")
	assert_eq(Texts.t(&"noSuchKey"), "noSuchKey")


func test_a_missing_argument_is_an_error() -> void:
	TranslationServer.set_locale("fr")
	expect_error("no argument \"count\"")
	expect_error("no argument \"count\"")
	assert_eq(Texts.t(&"unitScoutCount"), " éclaireur")


func test_has_tells_a_key_in_each_language_whatever_language_is_on() -> void:
	TranslationServer.set_locale("en")
	for locale in LANGUAGES:
		assert_true(Texts.has(&"unitScoutCount", locale), locale)
		assert_false(Texts.has(&"noSuchKey", locale), locale)
	assert_false(Texts.has(&"unitScoutCount", "de"))


func test_the_expected_texts_cover_every_key_with_an_argument() -> void:
	var expected := _expected()
	for locale in LANGUAGES:
		var keys: Dictionary = expected[locale]
		assert_eq(keys.size(), 262, locale)
		assert_has(keys, "guideRaidNeeded", locale)
		assert_has(keys, "saveMonth", locale)


func test_every_text_is_what_flutter_writes() -> void:
	var expected := _expected()
	var checked := 0
	for locale in LANGUAGES:
		TranslationServer.set_locale(locale)
		var keys: Dictionary = expected[locale]
		for key: String in keys:
			var cases: Array = keys[key]
			for case: Dictionary in cases:
				var args: Dictionary = case["args"]
				assert_eq(Texts.t(StringName(key), args), case["text"], "%s %s %s" % [locale, key, args])
				checked += 1
	assert_eq(checked, 1980)


func _expected() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(EXPECTED))
	var data: Dictionary = parsed
	return data

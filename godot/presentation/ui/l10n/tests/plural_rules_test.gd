extends TestCase
## The plural categories of the three languages, as Flutter's intl gives
## them: French reads 0 and 1 as singular, English and Spanish only 1.


func test_french_calls_zero_and_one_singular() -> void:
	assert_eq(PluralRules.category("fr", 0), "one")
	assert_eq(PluralRules.category("fr", 1), "one")
	assert_eq(PluralRules.category("fr", 2), "other")
	assert_eq(PluralRules.category("fr", 1000000), "other")


func test_english_and_spanish_call_only_one_singular() -> void:
	for locale: String in ["en", "es"]:
		assert_eq(PluralRules.category(locale, 0), "other", locale)
		assert_eq(PluralRules.category(locale, 1), "one", locale)
		assert_eq(PluralRules.category(locale, 2), "other", locale)
		assert_eq(PluralRules.category(locale, 21), "other", locale)


func test_a_region_is_ignored_and_an_unknown_language_reads_as_english() -> void:
	assert_eq(PluralRules.category("fr_CA", 0), "one")
	assert_eq(PluralRules.category("es_MX", 0), "other")
	assert_eq(PluralRules.category("de", 0), "other")
	assert_eq(PluralRules.category("de", 1), "one")

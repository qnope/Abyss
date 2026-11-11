extends TestCase
## test/presentation/extensions/decimal_extensions_test.dart, then every
## number of expected_decimals.json (what Flutter's NumberFormat writes, see
## README.md) in the three languages.

const EXPECTED := "res://presentation/ui/l10n/tests/expected_decimals.json"


func test_writes_a_decimal_the_way_each_language_does() -> void:
	assert_eq(LocalizedDecimal.format(1.5, "fr"), "1,5")
	assert_eq(LocalizedDecimal.format(1.5, "en"), "1.5")
	assert_eq(LocalizedDecimal.format(1.5, "es"), "1,5")


func test_keeps_one_digit_after_the_separator_by_default() -> void:
	assert_eq(LocalizedDecimal.format(2.0, "en"), "2.0")
	assert_eq(LocalizedDecimal.format(1.25, "fr", 2), "1,25")


func test_an_unknown_language_and_a_region_follow_the_rules_of_the_language() -> void:
	assert_eq(LocalizedDecimal.format(1234.5, "de"), "1,234.5")
	assert_eq(LocalizedDecimal.format(1234.5, "fr_CA"), "1 234,5")


func test_every_number_is_what_flutter_writes() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(EXPECTED))
	var expected: Dictionary = parsed
	var checked := 0
	for locale: String in expected:
		var cases: Array = expected[locale]
		for case: Dictionary in cases:
			var digits: int = case["digits"]
			var value: float = case["value"]
			assert_eq(LocalizedDecimal.format(value, locale, digits), case["text"], "%s %s digits %s" % [locale, value, digits])
			checked += 1
	assert_eq(checked, 288)

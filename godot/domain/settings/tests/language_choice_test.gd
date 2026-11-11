extends TestCase
## test/domain/settings/language_choice_test.dart.

const Choice := LanguageChoice.Value


func test_language_choice_offers_automatic_first_then_french_english_and_spanish() -> void:
	assert_eq(Choice.values(), [Choice.AUTOMATIC, Choice.FRENCH, Choice.ENGLISH, Choice.SPANISH])
	assert_eq(DartEnum.names(Choice), PackedStringArray(["automatic", "french", "english", "spanish"]))


func test_language_choice_stores_each_language_under_its_code_automatic_under_none() -> void:
	assert_null(LanguageChoice.code(Choice.AUTOMATIC))
	assert_eq(LanguageChoice.code(Choice.FRENCH), "fr")
	assert_eq(LanguageChoice.code(Choice.ENGLISH), "en")
	assert_eq(LanguageChoice.code(Choice.SPANISH), "es")


func test_language_choice_reads_back_every_choice_from_its_code() -> void:
	for choice: Choice in Choice.values():
		assert_eq(LanguageChoice.from_code(LanguageChoice.code(choice)), choice)


func test_language_choice_reads_an_unknown_or_missing_code_as_automatic() -> void:
	assert_eq(LanguageChoice.from_code(null), Choice.AUTOMATIC)
	assert_eq(LanguageChoice.from_code("de"), Choice.AUTOMATIC)
	assert_eq(LanguageChoice.from_code(""), Choice.AUTOMATIC)


## Not in the Dart file: a code that is no text, as a JSON file may hold.
func test_language_choice_reads_a_code_that_is_no_text_as_automatic() -> void:
	assert_eq(LanguageChoice.from_code(42), Choice.AUTOMATIC)
	assert_eq(LanguageChoice.from_code(0), Choice.AUTOMATIC)

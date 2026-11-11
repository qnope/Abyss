extends TextsTestCase
## test/presentation/extensions/language_choice_extensions_test.dart.

const Choice := LanguageChoice.Value


func test_a_language_is_named_in_itself_whatever_the_language_on() -> void:
	for locale in LANGUAGES:
		TranslationServer.set_locale(locale)
		assert_eq(LanguageChoiceTexts.label(Choice.FRENCH), "Français", locale)
		assert_eq(LanguageChoiceTexts.label(Choice.ENGLISH), "English", locale)
		assert_eq(LanguageChoiceTexts.label(Choice.SPANISH), "Español", locale)


func test_automatic_has_no_endonym_and_is_named_in_the_language_on() -> void:
	assert_null(LanguageChoiceTexts.endonym(Choice.AUTOMATIC))
	assert_eq(LanguageChoiceTexts.endonym(Choice.SPANISH), "Español")
	assert_eq(LanguageChoiceTexts.label(Choice.AUTOMATIC), "Automatique")
	TranslationServer.set_locale("en")
	assert_eq(LanguageChoiceTexts.label(Choice.AUTOMATIC), "Automatic")
	TranslationServer.set_locale("es")
	assert_eq(LanguageChoiceTexts.label(Choice.AUTOMATIC), "Automático")


func test_every_choice_but_automatic_has_an_endonym() -> void:
	for choice: int in Choice.values():
		assert_eq(LanguageChoiceTexts.endonym(choice as Choice) == null, choice == Choice.AUTOMATIC)
	assert_translated(&"settingsLanguageAutomatic")

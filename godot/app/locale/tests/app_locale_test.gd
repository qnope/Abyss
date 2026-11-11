extends TestCase
## test/presentation/l10n/abyss_locale_test.dart and
## language_choice_locale_test.dart, and the switch of the TranslationServer.

const Choice := LanguageChoice.Value

var temp := TempFolder.new()
var path := temp.path.path_join("settings.json")


func after_each() -> void:
	temp.remove()
	AppLocale.debug_reset()


func test_a_french_or_spanish_device_gets_its_language_and_any_other_english() -> void:
	assert_eq(AppLocale.resolve(Choice.AUTOMATIC, "fr"), "fr")
	assert_eq(AppLocale.resolve(Choice.AUTOMATIC, "es"), "es")
	assert_eq(AppLocale.resolve(Choice.AUTOMATIC, "en"), "en")
	assert_eq(AppLocale.resolve(Choice.AUTOMATIC, "de"), "en")
	assert_eq(AppLocale.resolve(Choice.AUTOMATIC, ""), "en")


func test_a_chosen_language_wins_over_the_device() -> void:
	assert_eq(AppLocale.resolve(Choice.FRENCH, "es"), "fr")
	assert_eq(AppLocale.resolve(Choice.ENGLISH, "fr"), "en")
	assert_eq(AppLocale.resolve(Choice.SPANISH, "de"), "es")


func test_every_choice_resolves_to_a_supported_language() -> void:
	for choice: int in Choice.values():
		assert_has(AppLocale.SUPPORTED, AppLocale.resolve(choice as Choice, "ja"))


func test_applies_the_saved_choice_at_startup() -> void:
	var settings := LanguageSettings.new(path)
	settings.choose(Choice.SPANISH)
	var locale := AppLocale.new(LanguageSettings.new(path), "fr")
	assert_eq(locale.locale(), "es")
	assert_eq(TranslationServer.get_locale(), "es")
	assert_eq(Texts.t(&"settingsLanguageAutomatic"), "Automático")


func test_follows_the_device_while_the_choice_is_automatic() -> void:
	var locale := AppLocale.new(LanguageSettings.new(path), "es")
	assert_eq(locale.locale(), "es")
	assert_eq(TranslationServer.get_locale(), "es")
	var other := AppLocale.new(LanguageSettings.new(path), "ja")
	assert_eq(other.locale(), "en")
	assert_eq(TranslationServer.get_locale(), "en")


func test_the_device_language_is_the_systems_by_default() -> void:
	var locale := AppLocale.new(LanguageSettings.new(path))
	assert_eq(locale.locale(), AppLocale.resolve(Choice.AUTOMATIC, OS.get_locale_language()))


func test_switches_when_the_player_picks_another_language() -> void:
	var settings := LanguageSettings.new(path)
	var locale := AppLocale.new(settings, "de")
	assert_eq(TranslationServer.get_locale(), "en")
	settings.choose(Choice.FRENCH)
	assert_eq(locale.locale(), "fr")
	assert_eq(TranslationServer.get_locale(), "fr")
	assert_eq(Texts.t(&"settingsLanguageAutomatic"), "Automatique")
	settings.choose(Choice.AUTOMATIC)
	assert_eq(locale.locale(), "en")
	assert_eq(TranslationServer.get_locale(), "en")


func test_the_reset_puts_the_game_back_in_french() -> void:
	TranslationServer.set_locale("es")
	AppLocale.debug_reset()
	assert_eq(TranslationServer.get_locale(), "fr")

extends UiTestCase
## The language the player picks reaches a mounted component: LanguageSettings
## tells AppLocale, which sets the TranslationServer, which tells every node,
## and a RefreshingPanel writes its texts again, with no wiring of its own.

var _temp := TempFolder.new()


func after_each() -> void:
	_temp.remove()


func test_a_mounted_panel_follows_the_language_the_player_picks() -> void:
	var settings := LanguageSettings.new(_temp.path.path_join("settings.json"))
	var locale := AppLocale.new(settings, "en")
	var tab := mount(TabPlaceholder.new(UiIcon.glyph_path(&"info"), "Tech")) as TabPlaceholder
	assert_eq(locale.locale(), "en")
	assert_eq(tab.soon_label.text, "Coming soon")
	settings.choose(LanguageChoice.Value.SPANISH)
	assert_eq(tab.soon_label.text, "Próximamente")
	settings.choose(LanguageChoice.Value.FRENCH)
	assert_eq(tab.soon_label.text, "Bientôt disponible")
	assert_eq(locale.locale(), "fr")


func test_an_open_dialog_follows_the_language_too() -> void:
	var settings := LanguageSettings.new(_temp.path.path_join("settings.json"))
	var locale := AppLocale.new(settings, "fr")
	var page := FullPage.new("Page")
	modals().open(page)
	assert_eq(page.back_button.tooltip_text, "Fermer")
	settings.choose(LanguageChoice.Value.ENGLISH)
	assert_eq(page.back_button.tooltip_text, "Close")
	assert_eq(locale.locale(), "en")

extends UiTestCase
## test/presentation/screens/menu/main_menu_language_test.dart: the settings
## outside a game offer the language and close.

var _chosen: Array[LanguageChoice.Value] = []


func test_offers_the_language_picker_and_a_way_to_close() -> void:
	var dialog := _open(LanguageChoice.Value.FRENCH)
	assert_eq(dialog.title(), "Paramètres")
	assert_true(dialog.picker.row(LanguageChoice.Value.FRENCH).check.visible)
	assert_eq(texts(dialog).size(), 8)
	press("Fermer")
	assert_null(current_modal())


func test_tells_the_language_picked() -> void:
	_open(LanguageChoice.Value.AUTOMATIC)
	press("English")
	assert_eq(_chosen, [LanguageChoice.Value.ENGLISH] as Array[LanguageChoice.Value])
	assert_not_null(current_modal(), "picking a language does not close the settings")


func test_follows_a_language_change_at_once() -> void:
	var dialog := _open(LanguageChoice.Value.AUTOMATIC)
	use_language("en")
	assert_eq(dialog.title(), "Settings")
	assert_eq(dialog.actions()[0].text, "Close")
	assert_eq(dialog.picker.title_label.text, "Language")
	assert_no_raw_keys()


func _open(current: LanguageChoice.Value) -> LanguageDialog:
	var dialog := LanguageDialog.new(current)
	dialog.language_chosen.connect(func(choice: LanguageChoice.Value) -> void: _chosen.append(choice))
	modals().open(dialog)
	return dialog

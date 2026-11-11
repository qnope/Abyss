extends UiTestCase
## MessageDialog: a line of news and an OK, in place of Flutter's snack bar.

var _said := "Descente au Niveau 2 effectuée"


func _dialog(title_text := "") -> MessageDialog:
	var dialog := MessageDialog.new(title_text, func() -> String: return _said)
	modals().open(dialog)
	return dialog


func test_it_says_the_message_with_an_ok() -> void:
	var dialog := _dialog()
	assert_eq(dialog.message_label.text, "Descente au Niveau 2 effectuée")
	assert_eq(dialog.ok_button.text, "OK")
	assert_eq(dialog.title(), "")


func test_a_title_is_shown_above() -> void:
	assert_eq(_dialog("Garnison").title(), "Garnison")


func test_ok_ends_the_dialog_with_nothing() -> void:
	var dialog := _dialog()
	press("OK")
	assert_true(dialog.is_closed())
	assert_null(current_modal())


func test_the_message_is_written_again_with_the_language() -> void:
	var dialog := _dialog()
	_said = "Done"
	use_language("en")
	assert_eq(dialog.message_label.text, "Done")
	assert_no_raw_keys(dialog)

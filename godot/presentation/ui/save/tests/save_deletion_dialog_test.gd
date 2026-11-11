extends UiTestCase
## The confirmation before a game is deleted for good
## (test/presentation/screens/menu/load_game_screen_actions_test.dart).

var _results: Array = []


func test_asks_before_deleting_the_game_of_the_player() -> void:
	var dialog := _open("Alice")
	assert_eq(dialog.title(), "Supprimer la partie ?")
	assert_eq(dialog.message_label.text, "La partie de Alice sera définitivement supprimée.")
	assert_eq(dialog.cancel_button.text, "Annuler")
	assert_eq(dialog.delete_button.text, "Supprimer")
	assert_eq(dialog.delete_button.get_theme_color(&"font_color"), AbyssColors.ERROR)
	assert_no_raw_keys()


func test_ends_with_true_only_when_confirmed() -> void:
	_open("Alice")
	press("Supprimer")
	assert_eq(_results, [true])


func test_cancelling_ends_with_false() -> void:
	_open("Alice")
	press("Annuler")
	assert_eq(_results, [false])


func test_dismissing_it_ends_with_nothing() -> void:
	_open("Alice")
	modals().close_top()
	assert_eq(_results, [null])


func test_follows_the_language() -> void:
	var dialog := _open("Alice")
	use_language("en")
	assert_eq(dialog.title(), "Delete this game?")
	assert_eq(dialog.cancel_button.text, "Cancel")
	assert_eq(dialog.delete_button.text, "Delete")
	assert_has(dialog.message_label.text, "Alice")


func _open(player_name: String) -> SaveDeletionDialog:
	var dialog := SaveDeletionDialog.new(player_name)
	dialog.closed.connect(func(result: Variant) -> void: _results.append(result))
	modals().open(dialog)
	return dialog

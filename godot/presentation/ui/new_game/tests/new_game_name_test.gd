extends NewGameCase
## test/presentation/screens/menu/new_game_screen_test.dart (and its keyboard
## test): the name the player gives, and what is said of a bad one.


func test_complains_of_an_empty_name() -> void:
	var screen := _screen()
	press("Commencer")
	assert_eq(screen.error_label.text, "Veuillez entrer un nom")
	assert_true(screen.error_label.visible)
	assert_eq(screen.name_field.theme_type_variation, &"ErrorLineEdit")
	assert_eq(_created.size(), 0)


func test_complains_of_a_name_that_is_too_short() -> void:
	var screen := _screen()
	_type(screen, "A")
	press("Commencer")
	assert_eq(screen.error_label.text, "Le nom doit contenir au moins 2 caractères")
	assert_eq(_created.size(), 0)


func test_counts_utf16_units_as_dart_does() -> void:
	assert_eq(NewGameScreen.name_error_key("😀"), &"")
	assert_eq(NewGameScreen.name_error_key("é"), &"newGameNameTooShort")
	assert_eq(NewGameScreen.name_error_key("   "), &"newGameNameEmpty")
	assert_eq(NewGameScreen.name_error_key(" ab "), &"")


func test_typing_clears_the_complaint() -> void:
	var screen := _screen()
	press("Commencer")
	_type(screen, "N")
	assert_false(screen.error_label.visible)
	assert_eq(screen.name_field.theme_type_variation, &"")


func test_enter_in_the_field_starts_the_game_too() -> void:
	var screen := _screen()
	_type(screen, "Nemo")
	screen.name_field.text_submitted.emit("Nemo")
	assert_eq(_created.size(), 1)

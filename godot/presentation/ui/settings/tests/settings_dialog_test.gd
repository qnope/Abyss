extends UiTestCase
## The settings of a game being played: the language, the guide switches and
## the ways out (settings_dialog_test.dart, settings_dialog_language_test.dart).

var _game: Game
var _actions: GameActions
var _acted: Array = []
var _languages: Array[LanguageChoice.Value] = []
var _results: Array = []


func before_each() -> void:
	_game = GameFactory.new_single_player("Nemo", 1)
	_game.human_player().saved_objective_state = ObjectiveState.new([], true, false)
	_actions = GameActions.new(_game)
	_actions.acted.connect(_acted.append)


func test_shows_the_language_above_the_game_and_its_guide() -> void:
	var dialog := _open()
	var shown := texts(dialog)
	assert_eq(dialog.title(), "Paramètres")
	assert_true(shown.find("Langue") < shown.find("Partie en cours"))
	assert_true(shown.find("Partie en cours") < shown.find("Guide du tutoriel"))
	assert_no_raw_keys()


func test_checks_the_language_of_the_player() -> void:
	var dialog := _open(LanguageChoice.Value.SPANISH)
	assert_true(dialog.picker.row(LanguageChoice.Value.SPANISH).check.visible)
	assert_false(dialog.picker.row(LanguageChoice.Value.FRENCH).check.visible)


func test_a_language_picked_is_told_and_spoken_at_once() -> void:
	var dialog := _open()
	press("English")
	assert_eq(_languages, [LanguageChoice.Value.ENGLISH] as Array[LanguageChoice.Value])
	use_language("en")
	assert_eq(dialog.title(), "Settings")
	assert_not_null(find_text("Tutorial guide", dialog))
	assert_eq(dialog.actions()[0].text, "Cancel")
	assert_eq(dialog.actions()[1].text, "Save and quit")


func test_the_guide_switches_go_through_the_actions() -> void:
	var dialog := _open()
	press(dialog.guide.guide_switch.switch)
	press(dialog.guide.tips_switch.switch)
	assert_eq(_acted, [null, null])
	var state := ObjectiveMigration.state_of(_game, _game.human_player())
	assert_false(state.tutorial_enabled)
	assert_true(state.tips_enabled)
	assert_false(dialog.is_closed(), "the dialog stays open")


func test_cancel_closes_without_a_way_out() -> void:
	_open()
	press("Annuler")
	assert_eq(_results, [SettingsDialog.CANCEL])
	assert_null(current_modal())
	assert_eq(_acted, [])


func test_save_and_quit_is_the_way_out() -> void:
	_open()
	press("Sauvegarder et quitter")
	assert_eq(_results, [SettingsDialog.SAVE_AND_QUIT])
	assert_null(current_modal())


func test_dismissing_it_is_no_way_out() -> void:
	_open()
	modals().close_top()
	assert_eq(_results, [null])


func test_the_story_row_asks_for_the_story() -> void:
	var dialog := _open()
	var told := [0]
	dialog.story_requested.connect(func() -> void: told[0] += 1)
	press("L'histoire du jeu")
	assert_eq(told[0], 1)
	assert_not_null(current_modal(), "the settings stay open")


func _open(choice := LanguageChoice.Value.FRENCH) -> SettingsDialog:
	var dialog := SettingsDialog.new(_actions, choice)
	dialog.language_chosen.connect(_languages.append)
	dialog.closed.connect(_results.append)
	modals().open(dialog)
	return dialog

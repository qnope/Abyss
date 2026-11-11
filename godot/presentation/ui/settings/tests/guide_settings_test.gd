extends UiTestCase
## The guide and tip switches of the settings, and the way to the opening
## story (guide_settings_test.dart, settings_dialog_test.dart).

var _game: Game
var _actions: GameActions
var _acted: Array = []
var _stories := 0


func before_each() -> void:
	_game = GameFactory.new_single_player("Nemo", 1)
	_game.human_player().saved_objective_state = ObjectiveState.new([], true, false)
	_actions = GameActions.new(_game)
	_actions.acted.connect(_acted.append)


func test_speaks_the_guide_switches_and_the_story_in_french() -> void:
	_settings()
	var shown: Array[String] = ["Guide du tutoriel",
		"Le guide te montre quoi faire, objectif après objectif", "Conseils",
		"Une fiche explique chaque nouveauté à sa première apparition", "L'histoire du jeu"]
	for words in shown:
		assert_not_null(find_text(words), words)
	assert_no_raw_keys()


func test_speaks_english_and_spanish() -> void:
	var settings := _settings()
	use_language("en")
	assert_not_null(find_text("Tutorial guide", settings))
	assert_not_null(find_text("A card explains each new feature the first time it shows up", settings))
	assert_not_null(find_text("The story of the game", settings))
	use_language("es")
	assert_not_null(find_text("Guía del tutorial", settings))
	assert_not_null(find_text("La historia del juego", settings))


func test_shows_the_switches_of_the_game() -> void:
	var settings := _settings()
	assert_true(settings.guide_switch.value())
	assert_false(settings.tips_switch.value())


func test_switching_the_guide_off_changes_the_game_through_the_actions() -> void:
	var settings := _settings()
	press(settings.guide_switch.switch)
	assert_false(settings.guide_switch.value())
	var state := ObjectiveMigration.state_of(_game, _game.human_player())
	assert_false(state.tutorial_enabled)
	assert_false(state.tips_enabled)
	assert_eq(_acted, [null])


func test_switching_the_tips_on_changes_the_game_through_the_actions() -> void:
	var settings := _settings()
	press(settings.tips_switch.switch)
	var state := ObjectiveMigration.state_of(_game, _game.human_player())
	assert_true(state.tips_enabled)
	assert_true(state.tutorial_enabled)
	assert_eq(_acted, [null])


func test_redraws_the_switches_from_the_game() -> void:
	var settings := _settings()
	_game.human_player().saved_objective_state.tips_enabled = true
	_game.human_player().saved_objective_state.tutorial_enabled = false
	settings.refresh()
	assert_false(settings.guide_switch.value())
	assert_true(settings.tips_switch.value())
	assert_eq(_acted, [], "a redraw is no change")


func test_the_story_row_asks_for_the_story() -> void:
	_settings()
	press("L'histoire du jeu")
	assert_eq(_stories, 1)
	assert_eq(_acted, [])


func _settings() -> GuideSettings:
	var settings := mount(GuideSettings.new(_actions)) as GuideSettings
	settings.story_requested.connect(func() -> void: _stories += 1)
	return settings

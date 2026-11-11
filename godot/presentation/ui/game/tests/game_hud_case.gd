class_name GameHudCase
extends UiTestCase
## What the tests of the game screen share: a new game for "Nemo", the
## actions that change it, and the HUD over a modal layer, with what it tells
## recorded.

var _game: Game
var _actions: GameActions
var _hud: GameHud
var _tabs: Array[GameTab.Value] = []
var _end_turns := 0
var _quits := 0
var _languages: Array[LanguageChoice.Value] = []


func before_each() -> void:
	_game = GameFactory.new_single_player("Nemo", 1)


## The HUD of [member _game], or of [param game] when given.
func _show(game: Game = null) -> GameHud:
	if game != null:
		_game = game
	_actions = GameActions.new(_game)
	_hud = GameHud.new(_actions, LanguageChoice.Value.FRENCH, modals())
	mount(_hud)
	_hud.tab_changed.connect(_tabs.append)
	_hud.end_turn_requested.connect(func() -> void: _end_turns += 1)
	_hud.quit_requested.connect(func() -> void: _quits += 1)
	_hud.language_chosen.connect(_languages.append)
	return _hud


## A game whose base holds the buildings of [param levels] only.
static func _game_with(levels: Dictionary[BuildingType.Value, int]) -> Game:
	return GameSamples.game([GameSamples.player_with("Nemo", levels)])

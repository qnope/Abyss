class_name NewGameCase
extends UiTestCase
## What the tests of the new game screen share: the screen mounted, the games
## it created and the backs it told, and typing a name.

var _created: Array[Game] = []
var _backs := 0
var _open_screen: NewGameScreen


func _screen(saved: Array[Game] = [], map_seed: Variant = 1) -> NewGameScreen:
	var screen := mount(NewGameScreen.new(saved, map_seed)) as NewGameScreen
	_open_screen = screen
	screen.game_created.connect(func(game: Game) -> void: _created.append(game))
	screen.back_pressed.connect(func() -> void: _backs += 1)
	return screen


## Types [param name_written] and presses Start, after the setup [param before].


func _start(name_written: String, before := Callable()) -> void:
	_type(_open_screen, name_written)
	if before.is_valid():
		before.call()
	press("Commencer")


func _type(screen: NewGameScreen, typed: String) -> void:
	screen.name_field.text = typed
	screen.name_field.text_changed.emit(typed)

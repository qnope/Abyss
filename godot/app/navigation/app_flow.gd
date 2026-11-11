class_name AppFlow
extends RefCounted
## The way between the screens (the Navigator of lib/main.dart and the
## screens of lib/presentation/screens/menu/): one screen shows at a time on
## [member screens], and each leads to the next.
##
##     menu -> new game -> opening story -> the game
##     menu -> saved games -> the game (a lost game too, until its own screen)
##     the game -> (settings: save and quit) -> menu
##
## The screens only tell what the player wants, with signals; the flow saves
## and deletes through the GameRepository and shows what follows, never
## waiting: a chain of signals, no await. The saves are read again each time
## a screen is shown, so that it shows what the folder holds.

## A screen shows: whether it is the game being played, over the world the
## player moves in, or a menu over its ambience.
signal playing_changed(playing: bool)

## The screen on show, null before the first.
var current: Control
## What runs the game on show, null while a menu shows.
var controller: GameController
## The files the last read of the saves skipped, by name, with why.
var unreadable: Dictionary[String, String] = {}
var repository: GameRepository
var language: LanguageSettings
var screens: Control
## The 3D world behind the screens: the game shows its base there.
var world: WorldHost
var _modals: ModalLayer


## Shows its screens on [param screens_], and their dialogs on [param modals];
## a game shows its base in [param world_].
func _init(repository_: GameRepository, language_: LanguageSettings, screens_: Control,
		modals: ModalLayer, world_: WorldHost) -> void:
	repository = repository_
	language = language_
	screens = screens_
	world = world_
	_modals = modals


func show_menu() -> void:
	var menu := MainMenuScreen.new(SaveSections.of(_read_saves()), language.choice(), _modals)
	menu.continue_requested.connect(play)
	menu.new_game_requested.connect(show_new_game)
	menu.load_game_requested.connect(show_load_game)
	menu.language_chosen.connect(_choose_language)
	_show(menu, false)


func show_new_game() -> void:
	var screen := NewGameScreen.new(_read_saves())
	screen.back_pressed.connect(show_menu)
	screen.game_created.connect(_begin)
	_show(screen, false)


func show_load_game() -> void:
	var screen := LoadGameScreen.new(SaveSections.of(_read_saves()), _modals)
	screen.back_pressed.connect(show_menu)
	screen.game_chosen.connect(play)
	screen.delete_confirmed.connect(_delete)
	screen.new_game_requested.connect(show_new_game)
	_show(screen, false)


## The story that opens a new game, then the game.
func show_story(game: Game) -> void:
	var story := OpeningStoryScreen.new()
	story.finished.connect(play.bind(game))
	_show(story, false)


## The game [param game], where it stands: its screen over its base in the
## world, every change of it saved (GameSession).
func play(game: Game) -> void:
	_leave_game()
	var session := GameSession.new(game, repository)
	var screen := GameHud.new(session.actions, language.choice(), _modals)
	controller = GameController.new(session, screen, world)
	controller.quit_requested.connect(_quit.bind(game))
	controller.language_chosen.connect(_choose_language)
	_show(screen, true)


func _begin(game: Game) -> void:
	GameSession.save_game(repository, game)
	show_story(game)


func _quit(game: Game) -> void:
	GameSession.save_game(repository, game)
	show_menu()


func _delete(game: Game) -> void:
	var error := repository.delete_game(game)
	if error != OK:
		push_warning("The game of %s could not be deleted: %s" % [
			game.human_player().name, error_string(error)])
	show_load_game()


func _choose_language(choice: LanguageChoice.Value) -> void:
	var error := language.choose(choice)
	if error != OK:
		push_warning("The language could not be saved: %s" % error_string(error))


## The games saved; a file that cannot be read is told and skipped.
func _read_saves() -> Array[Game]:
	var found := repository.load_all()
	unreadable = found.unreadable
	for file in unreadable:
		push_warning("The save %s was skipped: %s" % [file, unreadable[file]])
	return found.games


## Puts [param screen] in place of the one on show. The old one may be the
## node whose signal led here, so it goes at the end of the frame.
func _show(screen: Control, playing: bool) -> void:
	if not playing:
		_leave_game()
	if current != null:
		screens.remove_child(current)
		current.queue_free()
	current = screen
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screens.add_child(screen)
	playing_changed.emit(playing)


## Gives the world back to the menus when a game was on show.
func _leave_game() -> void:
	if controller != null:
		controller.close()
		controller = null

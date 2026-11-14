class_name AppFlow
extends RefCounted
## The way between the screens (the Navigator of lib/main.dart and the
## screens of lib/presentation/screens/menu/): one screen shows at a time on
## [member screens], and each leads to the next.
##
##     menu -> new game -> opening story -> the game
##     menu -> saved games -> the game, or the defeat screen of a lost game
##     the game -> (settings: save and quit) -> menu
##     the game -> a turn lost it -> the defeat screen -> menu or replay export
##
## The screens only tell what the player wants, with signals; the flow saves
## and deletes through the GameRepository and shows what follows, no await.

## A screen shows: whether it is the game, over the world, or a menu.
signal playing_changed(playing: bool)

var current: Control
var controller: GameController
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


func show_story(game: Game) -> void:
	var story := OpeningStoryScreen.new()
	story.finished.connect(play.bind(game))
	_show(story, false)


## The game [param game], where it stands: its screen over its base in the
## world, every change of it saved (GameSession). A lost game reopens on its
## defeat screen (lib/presentation/screens/game/resume_game.dart).
func play(game: Game) -> void:
	if game.status == GameStatus.Value.DEFEAT:
		show_defeat(game)
		return
	_leave_game()
	var session := GameSession.new(game, repository)
	var screen := GameHud.new(session.actions, language.choice(), _modals)
	controller = GameController.new(session, screen, world, _modals)
	controller.quit_requested.connect(_quit)
	controller.defeated.connect(show_defeat.bind(game))
	controller.language_chosen.connect(_choose_language)
	_show(screen, true)


## The defeat screen of the lost [param game], the menu its only way out.
func show_defeat(game: Game) -> void:
	var screen := GameOverScreens.defeat(game)
	screen.menu_requested.connect(show_menu)
	screen.export_requested.connect(func() -> void: _modals.open(ReplayExportDialog.new(game)))
	_show(screen, false)


## The app goes away or behind another: a save that waits is written at once.
func flush() -> void:
	if controller != null:
		controller.session.flush()


func _begin(game: Game) -> void:
	GameSession.save_game(repository, game)
	show_story(game)


func _quit() -> void:
	controller.session.save()
	show_menu()


func _delete(game: Game) -> void:
	var error := repository.delete_game(game)
	if error != OK:
		push_warning("The game of %s could not be deleted: %s" % [game.human_player().name, error_string(error)])
	show_load_game()


func _choose_language(choice: LanguageChoice.Value) -> void:
	var error := language.choose(choice)
	if error != OK:
		push_warning("The language could not be saved: %s" % error_string(error))


## The games saved, read again for each screen; a file that cannot be read is told and skipped.
func _read_saves() -> Array[Game]:
	var found := repository.load_all()
	unreadable = found.unreadable
	for file in unreadable:
		push_warning("The save %s was skipped: %s" % [file, unreadable[file]])
	return found.games


## Puts [param screen] in place of the one on show, freed at the end of the frame.
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


func _leave_game() -> void:
	if controller != null:
		controller.close()
		controller = null

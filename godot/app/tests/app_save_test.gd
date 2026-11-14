extends UiTestCase
## The app going away or behind another: the window closing or losing the
## focus, the back key, a phone pausing the app, the app leaving the tree.
## The frame a change waits for to be saved may never come, so the save is
## written at once.

const MainScene := preload("res://app/main.tscn")

var _folder: TempFolder
var _repository: GameRepository


func before_each() -> void:
	_folder = TempFolder.new()
	add_cleanup(_folder.remove)
	add_cleanup(_forget_the_window)
	_repository = GameRepository.new(_folder.path.path_join("saves"))


func test_a_change_of_the_game_waits_for_the_next_frame() -> void:
	var app := _play()
	_change(app, 15)
	assert_eq(_saved_turn(), 14)
	assert_true(app.flow.controller.session.is_save_waiting())


func test_writes_the_save_that_waits_when_the_app_goes_away() -> void:
	var app := _play()
	var turn := 14
	for what: int in [Node.NOTIFICATION_WM_CLOSE_REQUEST, Node.NOTIFICATION_WM_GO_BACK_REQUEST,
			Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT, Node.NOTIFICATION_APPLICATION_FOCUS_OUT,
			Node.NOTIFICATION_APPLICATION_PAUSED]:
		turn += 1
		_change(app, turn)
		app.notification(what)
		assert_eq(_saved_turn(), turn, "notification %d" % what)
		assert_false(app.flow.controller.session.is_save_waiting())


func test_writes_the_save_that_waits_when_the_app_leaves_the_tree() -> void:
	var app := _play()
	_change(app, 15)
	app.get_parent().remove_child(app)
	assert_eq(_saved_turn(), 15)
	app.free()


func test_the_app_coming_back_writes_nothing() -> void:
	var app := _play()
	_change(app, 15)
	app.notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_IN)
	app.notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	assert_eq(_saved_turn(), 14)
	assert_true(app.flow.controller.session.is_save_waiting())


func test_a_menu_has_no_game_to_write() -> void:
	var app := _app()
	app.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	assert_true(app.flow.current is MainMenuScreen)
	assert_eq(_repository.load_all().games.size(), 0)


func test_a_bench_has_no_game_to_write() -> void:
	var app := _app(BenchOptions.new(10.0))
	app.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	assert_null(app.flow)
	assert_eq(_repository.load_all().games.size(), 0)


## The app playing the saved game of Alice, at its turn 14.
func _play() -> App:
	_repository.save(SavedGameSamples.game("Alice", 14))
	var app := _app()
	press("CONTINUER")
	return app


## The player changes the game on show: its turn is [param turn].
func _change(app: App, turn: int) -> void:
	app.flow.controller.session.actions.mark(func(game: Game) -> void: game.turn = turn)


## The turn of the game as the disk holds it.
func _saved_turn() -> int:
	return _repository.load_all().games[0].turn


## The app on saves and settings of this test, mounted in the window; a
## [param bench] of zero seconds is a launch with none.
func _app(bench := BenchOptions.new(0.0)) -> App:
	var app := MainScene.instantiate() as App
	app.repository = GameRepository.new(_folder.path.path_join("saves"))
	app.language = LanguageSettings.new(_folder.path.path_join("settings.json"))
	app.language.choose(LanguageChoice.Value.FRENCH)
	app.bench = bench
	return mount(app) as App


func _forget_the_window() -> void:
	var window := (Engine.get_main_loop() as SceneTree).root
	window.theme = null
	window.use_hdr_2d = false
	window.scaling_3d_scale = 1.0
	AppLocale.debug_reset()

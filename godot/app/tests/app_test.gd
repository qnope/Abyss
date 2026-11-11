extends UiTestCase
## The app: the game's theme on the window, the menus over the 3D world, the
## language of the player, a game begun and left, and the prototype a bench
## opens. The saves and the settings of every test are in a folder of its own.

const MainScene := preload("res://app/main.tscn")

var _folder: TempFolder


func before_each() -> void:
	_folder = TempFolder.new()
	add_cleanup(_folder.remove)
	add_cleanup(_forget_the_window)


func test_gives_the_window_the_abyss_theme() -> void:
	_app()
	var theme := (Engine.get_main_loop() as SceneTree).root.theme
	assert_not_null(theme)
	assert_eq(theme.get_type_variation_base("HudPanel"), &"PanelContainer")


func test_opens_on_the_menu_over_the_world() -> void:
	var app := _app()
	assert_true(app.flow.current is MainMenuScreen)
	assert_not_null(find_text("NOUVELLE PARTIE", app))
	assert_true(app.world.base.camera.current)
	assert_true(app.world.drifting)
	assert_eq(app.mouse_filter, Control.MOUSE_FILTER_IGNORE)


func test_stacks_the_world_the_screens_and_the_modals() -> void:
	var app := _app()
	assert_eq(app.get_children(), [app.world, app.screens, app.modals] as Array[Node])
	assert_eq(app.screens.get_child_count(), 1)


func test_keeps_the_screens_off_the_notch() -> void:
	var app := _app()
	assert_eq(app.screens.get_theme_constant("margin_top"), SafeArea.top(app.get_viewport()))


func test_opens_the_saves_and_the_settings_of_the_player_unless_told_otherwise() -> void:
	var app := MainScene.instantiate() as App
	app.bench = BenchOptions.new(0.0)
	mount(app)
	assert_eq(app.repository.folder, GameRepository.FOLDER)
	assert_eq(app.language.path, LanguageSettings.PATH)


func test_speaks_the_language_of_the_player_or_the_device() -> void:
	var app := _app()
	assert_eq(app.locale.locale(), "fr")
	assert_eq(TranslationServer.get_locale(), "fr")
	var automatic := MainScene.instantiate() as App
	automatic.language = LanguageSettings.new(_folder.path.path_join("other.json"))
	automatic.repository = app.repository
	automatic.bench = BenchOptions.new(0.0)
	mount(automatic)
	assert_eq(automatic.locale.locale(), AppLocale.resolve(LanguageChoice.Value.AUTOMATIC, OS.get_locale_language()))


func test_begins_a_game_and_leaves_it() -> void:
	var app := _app()
	press("NOUVELLE PARTIE")
	var screen := app.flow.current as NewGameScreen
	screen.name_field.text = "Alice"
	press(screen.start_button)
	assert_true(app.flow.current is OpeningStoryScreen)
	assert_true(app.world.drifting)
	press("Passer")
	assert_true(app.flow.current is GameHud)
	assert_not_null(find_text("Tour 1", app))
	assert_false(app.world.drifting, "the camera is the player's")
	(app.flow.current as GameHud).open_settings()
	press("Sauvegarder et quitter")
	assert_true(app.flow.current is MainMenuScreen)
	assert_true(app.world.drifting)
	assert_not_null(find_text("CONTINUER", app))
	assert_eq(app.repository.load_all().games.size(), 1)
	assert_eq(DirAccess.get_files_at(_folder.path.path_join("saves")), PackedStringArray(["game-1.json"]))


func test_resumes_a_saved_game_from_the_menu() -> void:
	var saved := GameRepository.new(_folder.path.path_join("saves"))
	saved.save(SavedGameSamples.game("Alice", 14))
	var app := _app()
	press("CONTINUER")
	assert_not_null(find_text("Tour 14", app))
	assert_false(app.world.drifting)


func test_skips_a_save_it_cannot_read_and_shows_the_others() -> void:
	var saved := GameRepository.new(_folder.path.path_join("saves"))
	saved.save(SavedGameSamples.game("Alice"))
	var broken := FileAccess.open(saved.folder.path_join("game-2.json"), FileAccess.WRITE)
	broken.store_string("{")
	broken.close()
	var app := _app()
	assert_not_null(find_text("CONTINUER", app))
	assert_eq(app.flow.unreadable.keys(), ["game-2.json"])


func test_speaks_the_language_picked_in_the_settings_at_once_and_keeps_it() -> void:
	var app := _app()
	add_cleanup(AppLocale.debug_reset)
	(app.flow.current as MainMenuScreen).settings_button.pressed.emit()
	press("English")
	assert_eq(app.language.choice(), LanguageChoice.Value.ENGLISH)
	assert_eq(app.locale.locale(), "en")
	assert_not_null(find_text("NEW GAME", app))
	assert_not_null(find_text("Close", app))
	press("Close")
	assert_null(app.modals.top())
	var reopened := LanguageSettings.new(app.language.path)
	assert_eq(reopened.choice(), LanguageChoice.Value.ENGLISH)


func test_opens_the_prototype_alone_for_a_bench() -> void:
	var app := _app(BenchOptions.new(10.0))
	assert_null(app.flow)
	assert_eq(app.get_child_count(), 1)
	var prototype := app.get_child(0) as Prototype
	assert_eq(prototype.bench.seconds, 10.0)
	assert_eq(prototype.find_children("*", "BenchRun", false, false).size(), 1)


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

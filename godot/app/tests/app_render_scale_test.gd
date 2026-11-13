extends UiTestCase
## The app caps the 3D of its window from the screen's density when it
## starts, for the menus and the game as for the prototype a bench opens,
## whose quality panel then scales what the game draws.

const MainScene := preload("res://app/main.tscn")

var _folder: TempFolder


func before_each() -> void:
	_folder = TempFolder.new()
	add_cleanup(_folder.remove)
	add_cleanup(_forget_the_window)


func test_draws_the_3d_of_a_dense_screen_at_twice_the_points() -> void:
	var app := _app(3.0)
	assert_almost_eq(_window().scaling_3d_scale, 2.0 / 3.0, 1e-6)
	assert_true(app.flow.current is MainMenuScreen)


func test_leaves_a_screen_of_density_1_or_2_at_its_pixels() -> void:
	_app(2.0)
	assert_eq(_window().scaling_3d_scale, 1.0)


func test_a_bench_measures_what_the_game_draws() -> void:
	var app := _app(3.0, BenchOptions.new(10.0))
	assert_almost_eq(_window().scaling_3d_scale, 2.0 / 3.0, 1e-6)
	var prototype := app.get_child(0) as Prototype
	prototype.quality.button(QualityPanel.SCALE, 0.75).button_pressed = true
	assert_almost_eq(_window().scaling_3d_scale, 0.5, 1e-6, "three quarters of the game's")
	prototype.quality.button(QualityPanel.SCALE, 1.0).button_pressed = true
	assert_almost_eq(_window().scaling_3d_scale, 2.0 / 3.0, 1e-6)


## The app on a screen of [param density], on saves and settings of this test.
func _app(density: float, bench := BenchOptions.new(0.0)) -> App:
	var app := MainScene.instantiate() as App
	app.repository = GameRepository.new(_folder.path.path_join("saves"))
	app.language = LanguageSettings.new(_folder.path.path_join("settings.json"))
	app.language.choose(LanguageChoice.Value.FRENCH)
	app.bench = bench
	app.density = density
	return mount(app) as App


func _window() -> Window:
	return (Engine.get_main_loop() as SceneTree).root


func _forget_the_window() -> void:
	_window().theme = null
	_window().use_hdr_2d = false
	_window().scaling_3d_scale = 1.0
	AppLocale.debug_reset()

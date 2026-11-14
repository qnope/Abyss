extends UiTestCase
## The app when the launch asks for a bench of the game's actions
## (`?bench=20&scene=game`): the real game in place of the prototype, on saves
## that are not the player's, and nothing of the bench in a normal launch.

const MainScene := preload("res://app/main.tscn")

var _folder: TempFolder


func before_each() -> void:
	_folder = TempFolder.new()
	add_cleanup(_folder.remove)
	add_cleanup(_forget_the_window)


func test_opens_the_real_game_for_a_bench_of_its_actions() -> void:
	var app := _app(BenchOptions.new(10.0, BenchOptions.GAME))
	assert_eq(app.get_children(), [app.world, app.screens, app.modals] as Array[Node], "no prototype")
	var hud := app.flow.current as GameHud
	assert_not_null(hud)
	assert_eq(hud.tab, GameTab.Value.MAP)
	assert_false(app.world.drifting, "the camera is the player's")
	assert_eq(app.screens.get_theme_constant("margin_top"), SafeArea.top(app.get_viewport()))
	var benches := app.find_children("*", "BenchLayer", true, false)
	assert_eq(benches.size(), 1)
	assert_eq((benches[0] as BenchLayer).run.stats.count(), 0)


func test_saves_the_bench_s_game_out_of_the_player_s_saves() -> void:
	var players := _folder.path.path_join("saves")
	GameRepository.new(players).save(SavedGameSamples.game("Alice"))
	var app := _app(BenchOptions.new(10.0, BenchOptions.GAME))
	assert_eq(app.repository.folder, _folder.path.path_join("bench"))
	assert_eq(app.flow.repository, app.repository)
	var bench := app.find_children("*", "BenchLayer", true, false)[0] as BenchLayer
	bench.run._process(Bench.WARM_UP)
	for i in 40:
		bench.run._process(1.0 / 60.0)
	app.flow.flush()
	assert_eq(DirAccess.get_files_at(app.repository.folder), PackedStringArray(["game-1.json"]))
	assert_eq(DirAccess.get_files_at(players), PackedStringArray(["game-1.json"]), "Alice's alone")
	bench.run._process(10.0)
	assert_false(DirAccess.dir_exists_absolute(app.repository.folder), "removed at the end")
	assert_eq(DirAccess.get_files_at(players), PackedStringArray(["game-1.json"]))


func test_opens_the_prototype_for_a_bench_of_the_map() -> void:
	var app := _app(BenchOptions.new(10.0, BenchOptions.MAP, 2))
	assert_null(app.flow)
	assert_eq((app.get_child(0) as Prototype).map.level, 2)


func test_shows_no_frame_counter_over_a_normal_game() -> void:
	var app := _app()
	assert_eq(app.repository.folder, _folder.path.path_join("saves"))
	app.flow.play(SavedGameSamples.game("Alice"))
	assert_true(app.flow.current is GameHud)
	for type: String in ["FrameCounter", "BenchLayer", "Bench"]:
		assert_eq(app.find_children("*", type, true, false).size(), 0, type)


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

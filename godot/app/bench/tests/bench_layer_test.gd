extends UiTestCase
## The bench of the actions laid over the real game: the bench game played
## through the flow on its Map tab, the frame counter over it, the actions
## played and timed, and its save removed at the end.

var _folder: TempFolder
var _saves: BenchSaves
var _flow: AppFlow
var _world: WorldHost
var _bench: BenchLayer


func before_each() -> void:
	_folder = TempFolder.new()
	add_cleanup(_folder.remove)
	_saves = BenchSaves.new(GameRepository.new(_folder.path.path_join("saves")))
	_world = WorldHost.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_world)
	add_cleanup(_world.free)
	_flow = AppFlow.new(_saves.repository, LanguageSettings.new(_folder.path.path_join("settings.json")),
		mount(Control.new()), modals(), _world)
	_bench = BenchLayer.open(_flow, _saves, 10.0)


func test_plays_the_bench_game_on_its_map_tab() -> void:
	var hud := _flow.current as GameHud
	assert_not_null(hud)
	assert_eq(hud.game.human_player().name, "Bench")
	assert_eq(hud.game.players.size(), 4)
	assert_eq(hud.tab, GameTab.Value.MAP)
	assert_eq(_world.view, WorldHost.View.MAP)
	assert_eq(_world.map.level, 1)


func test_lays_the_frame_counter_over_the_game() -> void:
	var hud := _flow.current as GameHud
	assert_eq(_bench.get_parent(), hud.content, "in the area the bars leave clear")
	assert_eq(_bench.counter.get_parent(), _bench)
	assert_eq(_bench.mouse_filter, Control.MOUSE_FILTER_IGNORE, "the touches reach the game")
	assert_eq(_bench.counter.size_flags_horizontal, Control.SIZE_SHRINK_BEGIN)
	assert_eq(_bench.counter.size_flags_vertical, Control.SIZE_SHRINK_END, "at its foot, under the level bar")
	assert_eq(_bench.get_theme_constant("margin_left"), BenchLayer.MARGIN)
	assert_eq(_bench.counter.theme_type_variation, &"HudPanel")


func test_plays_actions_that_go_the_whole_way_of_a_real_one() -> void:
	var redrawn: Array[int] = []
	_flow.controller.session.changed.connect(func() -> void: redrawn.append(1))
	_bench.run._process(Bench.WARM_UP)
	for i in 40:
		_bench.run._process(1.0 / 60.0)
	assert_eq(redrawn.size(), 1, "the screen is redrawn")
	assert_true(_flow.controller.session.is_save_waiting(), "its save waits for the next frame")
	_flow.controller.session.flush()
	assert_eq(DirAccess.get_files_at(_saves.repository.folder), PackedStringArray(["game-1.json"]),
		"and the game saved")
	assert_null(modals().top(), "nothing opens over the game")


func test_sums_up_on_the_counter_and_removes_its_save() -> void:
	_bench.run._process(Bench.WARM_UP)
	for i in 40:
		_bench.run._process(1.0 / 60.0)
	_bench.run._process(10.0)
	assert_true(_bench.counter.line(4).visible)
	assert_has(_bench.counter.line(4).text, "Bench 10 s on game: ")
	assert_has(_bench.counter.line(4).text, " · action ")
	assert_false(DirAccess.dir_exists_absolute(_saves.repository.folder))


func test_removes_its_save_after_the_save_of_the_last_action() -> void:
	var folder := _saves.repository.folder
	var session := _flow.controller.session
	_bench.run._process(Bench.WARM_UP)
	while not session.is_save_waiting():
		_bench.run._process(1.0 / 60.0)
	_bench.run._process(10.0)
	assert_true(session.is_save_waiting(), "the time is up, the action's frames are not in")
	# The save falls on the frame after the action's.
	session.flush()
	assert_true(DirAccess.dir_exists_absolute(folder))
	_bench.run._process(1.0 / 60.0)
	_bench.run._process(1.0 / 60.0)
	assert_false(DirAccess.dir_exists_absolute(folder))
	assert_true(_bench.counter.line(4).visible)

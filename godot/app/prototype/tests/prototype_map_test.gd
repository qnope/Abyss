extends TestCase
## The prototype when the launch asks for a bench on the map (`?bench=1&scene=map&level=2`):
## the map of that level in place of the base, lit as the level is, measured
## by a bench that says so.

const PrototypeScene := preload("res://app/prototype/prototype.tscn")

var _main: Prototype


func before_each() -> void:
	_main = PrototypeScene.instantiate() as Prototype
	_main.bench = BenchOptions.new(10.0, BenchOptions.MAP, 2)
	(Engine.get_main_loop() as SceneTree).root.add_child(_main)


func after_each() -> void:
	_main.free()
	_window().theme = null
	_window().use_hdr_2d = false
	_window().scaling_3d_scale = 1.0


func _window() -> Window:
	return (Engine.get_main_loop() as SceneTree).root


func test_shows_the_map_of_the_level_in_place_of_the_base() -> void:
	assert_not_null(_main.map)
	assert_eq(_main.map.level, 2)
	assert_true(_main.map.camera.current)
	assert_false(_main.base.visible)
	assert_eq(_main.base.process_mode, Node.PROCESS_MODE_DISABLED)


func test_lights_the_water_as_the_level() -> void:
	assert_eq(_main.base.water.environment.fog_light_color, LightMoods.depths().fog_colour)


func test_measures_the_map_and_says_so() -> void:
	var run: BenchRun = null
	for child in _main.get_children():
		if child is BenchRun:
			run = child
	assert_not_null(run)
	var summaries: Array[String] = []
	run.finished.connect(summaries.append)
	run._process(BenchRun.WARM_UP)
	run._process(11.0)
	assert_has(summaries[0], "on map level 2")


func test_applies_the_quality_chosen_to_the_map_too() -> void:
	var quality := _main.get_node("Hud/Top/QualityPanel") as QualityPanel
	quality.button(QualityPanel.PARTICLES).button_pressed = false
	assert_false(_main.map.surroundings.specks.emitting)
	quality.button(QualityPanel.SHADOWS).button_pressed = false
	assert_false(_main.map.key_light.shadow_enabled)


func test_fits_the_map_under_the_counter() -> void:
	var counter := _main.get_node("Hud/Top/FrameCounter") as FrameCounter
	var size := _main.get_viewport_rect().size
	var under := clampf(counter.get_global_rect().end.y / size.y, 0.0, 0.5)
	var fitted := OrbitFrame.fit(MapGrid.outline(_main.map.state.map.width, _main.map.state.map.height),
		MapRig.YAW, MapRig.PITCH, size.x / size.y, OrbitCamera.FOV, under + MapScene.LEVEL_BAR_ROOM)
	assert_almost_eq(_main.map.camera.rig.default_distance, fitted.x, 1e-3)

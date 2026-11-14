extends TestCase
## The frame counter: its figures rewritten a few times a second in the
## HUD's styles, and a bench's summary under them.

var _counter: FrameCounter


func before_each() -> void:
	_counter = FrameCounter.new()
	_root().add_child(_counter)


func after_each() -> void:
	_counter.free()


func test_is_a_hud_panel_that_lets_touches_through() -> void:
	assert_eq(_counter.theme_type_variation, &"HudPanel")
	assert_eq(_counter.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(_counter.line(0).theme_type_variation, &"HudHeadline")
	assert_eq(_counter.line(1).theme_type_variation, &"HudFigure")
	assert_eq(_counter.line(3).theme_type_variation, &"HudCaption")


func test_rewrites_its_lines_a_few_times_a_second() -> void:
	_counter._process(0.1)
	assert_eq(_counter.line(0).text, "– FPS", "not yet, but as tall as it will be")
	_counter._process(0.2)
	assert_eq(_counter.line(0).text, "7 FPS")
	assert_has(_counter.line(1).text, "ms avg")
	assert_has(_counter.line(2).text, "draw calls")
	assert_has(_counter.line(3).text, "%d×%d" % [_root().size.x, _root().size.y])


func test_shows_a_bench_once_run() -> void:
	assert_false(_counter.line(4).visible)
	_counter.show_bench("Bench 20 s")
	assert_true(_counter.line(4).visible)
	assert_eq(_counter.line(4).text, "Bench 20 s")


func test_wraps_a_long_summary_on_two_lines() -> void:
	_root().theme = AbyssTheme.build()
	_counter.show_bench(
		"Bench 20 s on map level 1: 59.7 FPS avg · 40.8 FPS 1% low · worst 110 ms · 6 slow frames")
	var summary := _counter.line(4)
	assert_eq(summary.get_combined_minimum_size().x, FrameCounter.BENCH_WIDTH)
	summary.size.x = FrameCounter.BENCH_WIDTH
	assert_eq(summary.get_line_count(), 2)
	_root().theme = null


func _root() -> Window:
	return (Engine.get_main_loop() as SceneTree).root

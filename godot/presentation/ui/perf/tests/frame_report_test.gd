extends TestCase
## The lines of the frame counter.


func test_writes_the_rate_and_the_frame_times() -> void:
	var stats := FrameStats.new(1.0)
	for i in 59:
		stats.add(1.0 / 60.0)
	stats.add(0.0333)
	assert_eq(FrameReport.headline(stats), "59 FPS")
	assert_eq(FrameReport.timing(stats), "16.9 ms avg · 33.3 ms worst")


func test_names_the_renderer_and_its_resolution() -> void:
	assert_eq(FrameReport.renderer("gl_compatibility", "opengl3", Vector2i(1170, 2532), 1.0),
		"Compatibility · opengl3 · 1170×2532")
	assert_eq(FrameReport.renderer("mobile", "metal", Vector2i(1170, 2532), 0.5),
		"Mobile · metal · 585×1266 (×0.5)")
	assert_eq(FrameReport.renderer("forward_plus", "vulkan", Vector2i(100, 100), 1.0),
		"Forward+ · vulkan · 100×100")


func test_rounds_the_scale_of_a_dense_screen() -> void:
	# A viewport keeps its scale as a 32-bit float: two thirds come back as 0.66666668...
	var kept := PackedFloat32Array([2.0 / 3.0])[0]
	assert_eq(FrameReport.renderer("gl_compatibility", "opengl3", Vector2i(1206, 2142), kept),
		"Compatibility · opengl3 · 804×1428 (×0.67)")


func test_counts_the_draw_calls_and_the_primitives() -> void:
	assert_eq(FrameReport.load(88, 212128), "88 draw calls · 212k primitives")
	assert_eq(FrameReport.load(3, 950), "3 draw calls · 950 primitives")
	assert_eq(FrameReport.load(120, 1520000), "120 draw calls · 1.52M primitives")


func test_sums_up_a_bench() -> void:
	var stats := FrameStats.new(INF)
	for i in 99:
		stats.add(0.02)
	stats.add(0.1)
	assert_eq(FrameReport.bench(stats, 20.0),
		"Bench 20 s: 48.1 FPS avg · 10.0 FPS 1% low · worst 100 ms · 1 slow frame")
	assert_eq(FrameReport.bench(stats, 20.0, "map level 2"),
		"Bench 20 s on map level 2: 48.1 FPS avg · 10.0 FPS 1% low · worst 100 ms · 1 slow frame",
		"it names the scene")


func test_tells_a_stop_from_frames_lost_here_and_there() -> void:
	var stop := FrameStats.new(INF)
	var lost := FrameStats.new(INF)
	for i in 594:
		stop.add(1.0 / 60.0)
		lost.add(1.0 / 60.0)
	stop.add(0.11)
	for i in 6:
		lost.add(1.0 / 30.0)
	assert_has(FrameReport.bench(stop, 10.0), "· worst 110 ms · 1 slow frame")
	assert_has(FrameReport.bench(lost, 10.0), "· worst 33 ms · 6 slow frames")
	var steady := FrameStats.new(INF)
	steady.add(1.0 / 60.0)
	assert_has(FrameReport.bench(steady, 10.0), "· worst 17 ms · 0 slow frames")

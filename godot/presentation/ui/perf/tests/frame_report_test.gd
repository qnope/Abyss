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


func test_counts_the_draw_calls_and_the_primitives() -> void:
	assert_eq(FrameReport.load(88, 212128), "88 draw calls · 212k primitives")
	assert_eq(FrameReport.load(3, 950), "3 draw calls · 950 primitives")
	assert_eq(FrameReport.load(120, 1520000), "120 draw calls · 1.52M primitives")


func test_sums_up_a_bench() -> void:
	var stats := FrameStats.new(INF)
	for i in 99:
		stats.add(0.02)
	stats.add(0.1)
	assert_eq(FrameReport.bench(stats, 20.0), "Bench 20 s: 48.1 FPS avg · 10.0 FPS 1% low")
	assert_eq(FrameReport.bench(stats, 20.0, "map level 2"),
		"Bench 20 s on map level 2: 48.1 FPS avg · 10.0 FPS 1% low", "it names the scene")

extends TestCase
## Frame times over a sliding window: the frame rate, the average and the
## worst frame, and the 1 % low of a whole run.


func test_reads_the_rate_and_the_times_of_its_frames() -> void:
	var stats := FrameStats.new(1.0)
	for i in 30:
		stats.add(1.0 / 60.0)
	stats.add(0.05)
	assert_eq(stats.count(), 31)
	assert_almost_eq(stats.fps(), 31.0 / (0.5 + 0.05), 1e-3)
	assert_almost_eq(stats.average_ms(), 550.0 / 31.0, 1e-3)
	assert_almost_eq(stats.worst_ms(), 50.0, 1e-3)


func test_keeps_only_its_window() -> void:
	var stats := FrameStats.new(1.0)
	stats.add(0.5)
	for i in 120:
		stats.add(1.0 / 60.0)
	assert_almost_eq(stats.fps(), 60.0, 0.5)
	assert_almost_eq(stats.worst_ms(), 1000.0 / 60.0, 1e-3, "the slow frame is gone")


func test_is_empty_at_first() -> void:
	var stats := FrameStats.new(1.0)
	assert_eq(stats.fps(), 0.0)
	assert_eq(stats.average_ms(), 0.0)
	assert_eq(stats.worst_ms(), 0.0)
	assert_eq(stats.low_fps(0.01), 0.0)


func test_reads_the_rate_of_its_slowest_frames() -> void:
	var stats := FrameStats.new(INF)
	for i in 198:
		stats.add(0.01)
	stats.add(0.05)
	stats.add(0.03)
	assert_almost_eq(stats.low_fps(0.01), 1.0 / 0.04, 1e-3, "the worst 2 of 200")
	assert_almost_eq(stats.low_fps(0.001), 1.0 / 0.05, 1e-3, "at least the worst one")


func test_starts_over() -> void:
	var stats := FrameStats.new(1.0)
	stats.add(0.02)
	stats.clear()
	assert_eq(stats.count(), 0)
	assert_eq(stats.fps(), 0.0)

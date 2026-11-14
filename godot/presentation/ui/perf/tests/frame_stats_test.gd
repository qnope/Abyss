extends TestCase
## Frame times over a sliding window: the frame rate, the average and the
## worst frame, and the 1 % low and the slow frames of a whole run.


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
	assert_eq(stats.slow_count(), 0)


func test_reads_the_rate_of_its_slowest_frames() -> void:
	var stats := FrameStats.new(INF)
	for i in 198:
		stats.add(0.01)
	stats.add(0.05)
	stats.add(0.03)
	assert_almost_eq(stats.low_fps(0.01), 1.0 / 0.04, 1e-3, "the worst 2 of 200")
	assert_almost_eq(stats.low_fps(0.001), 1.0 / 0.05, 1e-3, "at least the worst one")


func test_counts_the_frames_half_as_long_again_as_the_median() -> void:
	var stats := FrameStats.new(INF)
	for i in 100:
		stats.add(1.0 / 60.0)
	assert_eq(stats.slow_count(), 0, "a steady run has none")
	stats.add(0.024)
	assert_eq(stats.slow_count(), 0, "1.44 times the median is not slow")
	stats.add(0.026)
	stats.add(0.11)
	assert_eq(stats.slow_count(), 2, "a lost frame and a stop")


func test_counts_the_slow_frames_the_same_at_any_refresh_rate() -> void:
	var fast := FrameStats.new(INF)
	for i in 100:
		fast.add(1.0 / 120.0)
	fast.add(1.0 / 60.0)
	assert_eq(fast.slow_count(), 1, "a frame of 60 Hz is a lost one at 120 Hz")
	var slow := FrameStats.new(INF)
	for i in 100:
		slow.add(1.0 / 30.0)
	slow.add(0.045)
	assert_eq(slow.slow_count(), 0, "and 45 ms is no stop at 30 Hz")


func test_starts_over() -> void:
	var stats := FrameStats.new(1.0)
	stats.add(0.02)
	stats.clear()
	assert_eq(stats.count(), 0)
	assert_eq(stats.fps(), 0.0)

extends TestCase
## What every bench does: a warm-up, every frame of a set time timed, and its
## summary printed, shown on the frame counter and told at the end, once.

var _counter: FrameCounter
var _bench: Bench
var _summaries: Array[String] = []


func before_each() -> void:
	_counter = FrameCounter.new()
	_bench = Bench.new(_counter, 10.0, "nothing")
	_bench.finished.connect(_summaries.append)


func after_each() -> void:
	_counter.free()
	_bench.free()


func test_times_nothing_while_it_warms_up() -> void:
	_bench._process(Bench.WARM_UP - 0.1)
	assert_eq(_bench.stats.count(), 0)
	_bench._process(0.2)
	assert_eq(_bench.stats.count(), 0, "the frame that ended the warm-up is left out")


func test_times_every_frame_of_the_run() -> void:
	_bench._process(Bench.WARM_UP + 0.1)
	for i in 30:
		_bench._process(1.0 / 60.0)
	_bench._process(0.11)
	assert_eq(_bench.stats.count(), 31)
	assert_almost_eq(_bench.stats.worst_ms(), 110.0, 1e-3)
	assert_eq(_summaries.size(), 0)
	assert_false(_counter.line(4).visible)


func test_sums_up_once_at_the_end() -> void:
	_bench._process(Bench.WARM_UP + 0.1)
	for i in 300:
		_bench._process(1.0 / 60.0)
	_bench._process(5.1)
	assert_eq(_bench.stats.count(), 300, "the frame that ended after the time is left out")
	assert_eq(_summaries, [
		"Bench 10 s on nothing: 60.0 FPS avg · 60.0 FPS 1% low · worst 17 ms · 0 slow frames",
	] as Array[String])
	assert_eq(_counter.line(4).text, _summaries[0])
	assert_true(_counter.line(4).visible)
	assert_false(_bench.is_processing())
	_bench._process(1.0)
	assert_eq(_summaries.size(), 1, "a bench over stays over")

extends TestCase
## The bench: a warm-up, one turn around the base zooming in and out, every
## frame timed, and its summary shown at the end.

var _camera: OrbitCamera
var _counter: FrameCounter
var _bench: BenchRun
var _summaries: Array[String] = []


func before_each() -> void:
	_camera = OrbitCamera.new()
	_counter = FrameCounter.new()
	_bench = BenchRun.new(_camera, _counter, 10.0)
	_bench.finished.connect(_summaries.append)


func after_each() -> void:
	_camera.free()
	_counter.free()
	_bench.free()


func test_times_nothing_while_it_warms_up() -> void:
	_bench._process(BenchRun.WARM_UP - 0.1)
	assert_eq(_bench.stats.count(), 0)
	assert_eq(_camera.rig.yaw, OrbitRig.DEFAULT_YAW)


func test_turns_around_the_base_zooming_in_and_out() -> void:
	_bench._process(BenchRun.WARM_UP)
	_bench._process(5.0)
	assert_almost_eq(_camera.rig.yaw, OrbitRig.DEFAULT_YAW + 180.0, 1e-3)
	assert_almost_eq(_camera.rig.distance, OrbitRig.DEFAULT_DISTANCE * BenchRun.ZOOM, 1e-3)
	assert_eq(_bench.stats.count(), 1, "the frame that ended the warm-up is left out")


func test_sums_up_at_the_end() -> void:
	_bench._process(BenchRun.WARM_UP)
	for i in 600:
		_bench._process(1.0 / 60.0)
	_bench._process(0.1)
	assert_eq(_summaries.size(), 1)
	assert_has(_summaries[0], "Bench 10 s")
	assert_true(_counter.line(4).visible)
	assert_eq(_camera.rig.yaw, OrbitRig.DEFAULT_YAW, "back on the game's view")

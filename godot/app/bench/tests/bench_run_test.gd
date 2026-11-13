extends TestCase
## The bench: a warm-up, one turn around the base zooming in and out, every
## frame timed, and its summary shown at the end.

var _camera: OrbitCamera
var _counter: FrameCounter
var _bench: BenchRun
var _summaries: Array[String] = []


func before_each() -> void:
	_camera = OrbitCamera.new()
	_camera.rig.frame(25.0, 0.0)
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
	assert_almost_eq(_camera.rig.distance, 25.0 * BenchRun.ZOOM, 1e-3)
	assert_eq(_bench.stats.count(), 1, "the frame that ended the warm-up is left out")


func test_sums_up_at_the_end() -> void:
	_bench._process(BenchRun.WARM_UP)
	for i in 600:
		_bench._process(1.0 / 60.0)
	_bench._process(0.1)
	assert_eq(_summaries.size(), 1)
	assert_has(_summaries[0], "Bench 10 s on base:", "it names the scene")
	assert_true(_counter.line(4).visible)
	assert_eq(_camera.rig.yaw, OrbitRig.DEFAULT_YAW, "back on the game's view")
	assert_eq(_camera.rig.distance, 25.0, "the fitted one")


func test_follows_the_pose_it_is_given_and_names_its_scene() -> void:
	var shares: Array[float] = []
	var bench := BenchRun.new(_camera, _counter, 10.0,
		func(share: float, _zoom: float) -> void: shares.append(share), "map level 2")
	bench.finished.connect(_summaries.append)
	bench._process(BenchRun.WARM_UP)
	bench._process(5.0)
	assert_almost_eq(shares[0], 0.5, 1e-4)
	bench._process(6.0)
	assert_has(_summaries[0], "on map level 2")
	assert_eq(shares[-1], 0.0, "and back at the start")
	bench.free()

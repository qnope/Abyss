extends TestCase
## The bench of the game's actions: about twice a second an action that
## changes nothing but is told as any other, the longest of the three frames
## after it kept, and what an action costs at the end of the summary.

const FRAME := 1.0 / 60.0

var _game: Game
var _actions: GameActions
var _counter: FrameCounter
var _bench: ActionBench
var _acted: Array[Variant] = []
var _summaries: Array[String] = []


func before_each() -> void:
	_game = SavedGameSamples.game("Nemo", 7)
	_actions = GameActions.new(_game)
	_actions.acted.connect(_acted.append)
	_counter = FrameCounter.new()
	_bench = ActionBench.new(_actions, _counter, 10.0)
	_bench.finished.connect(_summaries.append)


func after_each() -> void:
	_counter.free()
	_bench.free()


func test_plays_no_action_while_it_warms_up() -> void:
	_bench._process(Bench.WARM_UP - 0.1)
	_bench._process(0.2)
	assert_eq(_acted.size(), 0)


func test_plays_an_action_about_twice_a_second() -> void:
	_bench._process(Bench.WARM_UP + FRAME)
	_frames(25)
	assert_eq(_acted.size(), 0, "not before half a second")
	_frames(75)
	assert_eq(_acted, [null, null, null] as Array[Variant], "three marks in a second and two thirds")
	assert_eq(_bench.stats.count(), 100, "every frame is timed")


func test_changes_nothing_in_the_game() -> void:
	var before := SaveCodec.to_text(_game)
	_bench._process(Bench.WARM_UP)
	_frames(40)
	assert_eq(_acted.size(), 1)
	assert_eq(SaveCodec.to_text(_game), before)


func test_keeps_the_longest_of_the_three_frames_after_an_action() -> void:
	_play_one()
	assert_eq(_bench.costs.count(), 0, "its frames are still to come")
	for seconds: float in [0.02, 0.09, 0.03]:
		_bench._process(seconds)
	assert_eq(_bench.costs.count(), 1)
	assert_almost_eq(_bench.costs.worst_ms(), 90.0, 1e-3, "the save fell on the second frame")
	_bench._process(0.2)
	assert_almost_eq(_bench.costs.worst_ms(), 90.0, 1e-3, "the fourth frame is not the action's")
	assert_almost_eq(_bench.stats.worst_ms(), 200.0, 1e-3, "but is a frame of the run")


func test_waits_for_the_frames_of_an_action_before_the_next() -> void:
	_play_one()
	_bench._process(0.6)
	_bench._process(0.6)
	assert_eq(_acted.size(), 1, "half a second has passed, but its frames are not all in")
	_bench._process(0.6)
	assert_eq(_acted.size(), 2)
	assert_almost_eq(_bench.costs.average_ms(), 600.0, 1e-2)


func test_ends_its_summary_with_what_an_action_costs() -> void:
	_play_one()
	for seconds: float in [0.08, 0.02, 0.02]:
		_bench._process(seconds)
	while _acted.size() < 2:
		_bench._process(FRAME)
	for seconds: float in [0.02, 0.02, 0.096]:
		_bench._process(seconds)
	_bench._process(10.0)
	assert_eq(_summaries.size(), 1)
	assert_true(_summaries[0].begins_with("Bench 10 s on game: "), _summaries[0])
	assert_true(_summaries[0].ends_with(" slow frames · action 88 ms avg, 96 worst"), _summaries[0])
	assert_eq(_counter.line(4).text, _summaries[0])


func test_waits_for_the_frames_of_an_action_the_end_cuts_short() -> void:
	_play_one()
	_bench._process(0.05)
	var timed := _bench.stats.count()
	_bench._process(10.0)
	assert_eq(_summaries.size(), 0, "its save may fall on the frame after it")
	_bench._process(FRAME)
	assert_eq(_summaries.size(), 1, "three frames after the action")
	assert_eq(_bench.costs.count(), 0, "and leaves it out of the costs")
	assert_has(_summaries[0], "action 0 ms avg, 0 worst")
	assert_eq(_bench.stats.count(), timed, "as the frames after the time")
	_bench._process(FRAME)
	assert_eq(_summaries.size(), 1)


## Runs the bench up to the frame that plays its first action.
func _play_one() -> void:
	_bench._process(Bench.WARM_UP)
	while _acted.is_empty():
		_bench._process(FRAME)


func _frames(count: int) -> void:
	for i in count:
		_bench._process(FRAME)

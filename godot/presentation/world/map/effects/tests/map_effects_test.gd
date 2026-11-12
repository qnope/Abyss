extends MapTestCase
## The effects of the map: one plays at a time, over when the map is out of
## sight or the player asked for fewer animations, ended on request.

var _effects: MapEffects
var _told: Array[String] = []
var _jolts: Array[float] = []


## An effect lasting [param length] seconds that shakes the view as it plays.
class Beat:
	extends MapEffect
	var length := 1.0

	func _init(length_ := 1.0) -> void:
		length = length_

	func duration() -> float:
		return length

	func jolt() -> float:
		return 0.5


func before_each() -> void:
	_effects = mounted(MapEffects.new()) as MapEffects
	_effects.jolted.connect(func(offset: float) -> void: _jolts.append(offset))


func _then(told: String) -> Callable:
	return func() -> void: _told.append(told)


func test_it_does_not_run_while_nothing_plays() -> void:
	assert_false(_effects.is_processing(), "a node with a _process runs from the moment it is ready")


func test_an_effect_plays_as_the_time_runs_and_then_is_told() -> void:
	var beat := Beat.new()
	_effects.play(beat, _then("done"))
	assert_true(_effects.is_playing())
	assert_eq(beat.get_parent(), _effects)
	assert_true(_effects.is_processing())
	_effects._process(0.4)
	assert_eq(beat.elapsed, 0.4)
	assert_eq(_jolts, [0.5] as Array[float], "it shakes the view while it plays")
	assert_eq(_told, [] as Array[String])
	_effects._process(0.7)
	assert_eq(_told, ["done"] as Array[String])
	assert_false(_effects.is_playing())
	assert_false(_effects.is_processing())
	assert_eq(_jolts, [0.5, 0.0] as Array[float], "the view rests when it is over")
	assert_true(beat.is_queued_for_deletion())
	assert_false(beat.visible, "gone at once, freed at the end of the frame")


func test_a_new_effect_ends_the_one_playing() -> void:
	var first := Beat.new()
	_effects.play(first, _then("first"))
	var second := Beat.new()
	_effects.play(second, _then("second"))
	assert_true(first.is_done)
	assert_eq(_told, ["first"] as Array[String])
	assert_eq(_effects.current, second)
	_effects.finish()
	assert_eq(_told, ["first", "second"] as Array[String])
	_effects.finish()
	assert_eq(_told.size(), 2, "nothing to end")


func test_what_is_told_afterwards_may_play_the_next_effect() -> void:
	var second := Beat.new()
	_effects.play(Beat.new(), func() -> void: _effects.play(second))
	_effects.finish()
	assert_eq(_effects.current, second, "the next one is the one playing")
	assert_true(_effects.is_processing())


func test_with_fewer_animations_an_effect_is_over_at_once_and_never_staged() -> void:
	_effects.reduced_motion = true
	var beat := Beat.new()
	_effects.play(beat, _then("done"))
	assert_eq(_told, ["done"] as Array[String])
	assert_false(is_instance_valid(beat), "it never reached the tree")
	assert_false(_effects.is_playing())


func test_with_the_map_out_of_sight_an_effect_is_over_at_once() -> void:
	_effects.hide()
	_effects.play(Beat.new())
	assert_false(_effects.is_playing())
	_effects.play(Beat.new(), _then("done"))
	assert_eq(_told, ["done"] as Array[String])

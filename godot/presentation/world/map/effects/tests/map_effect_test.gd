extends TestCase
## What every effect of the map does: plays out, ends once, can be ended early.

var _shown: Array[float] = []
var _ended := 0


## An effect of two seconds that notes the moments it shows.
class Two:
	extends MapEffect
	var shown: Array[float] = []

	func duration() -> float:
		return 2.0

	func _show(t: float) -> void:
		shown.append(t)


func test_a_bare_effect_takes_no_time_and_shakes_nothing() -> void:
	var bare := MapEffect.new()
	assert_eq(bare.duration(), 0.0)
	assert_eq(bare.jolt(), 0.0)
	bare.finished.connect(func() -> void: _ended += 1)
	bare.advance(0.1)
	assert_true(bare.is_done)
	assert_eq(_ended, 1)
	bare.free()


func test_it_shows_each_moment_and_ends_with_the_last() -> void:
	var effect := Two.new()
	effect.finished.connect(func() -> void: _ended += 1)
	effect.advance(0.5)
	effect.advance(0.5)
	assert_eq(effect.shown, [0.5, 1.0] as Array[float])
	assert_false(effect.is_done)
	effect.advance(5.0)
	assert_eq(effect.shown, [0.5, 1.0, 2.0] as Array[float], "never past its end")
	assert_true(effect.is_done)
	assert_eq(_ended, 1)
	effect.free()


func test_finishing_early_shows_the_last_moment_once() -> void:
	var effect := Two.new()
	effect.finished.connect(func() -> void: _ended += 1)
	effect.advance(0.5)
	effect.finish()
	effect.finish()
	effect.advance(1.0)
	assert_eq(effect.shown, [0.5, 2.0] as Array[float])
	assert_eq(effect.elapsed, 2.0)
	assert_eq(_ended, 1, "it ends once")
	effect.free()

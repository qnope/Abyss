extends TestCase
## What each side lost in each round, floating up.

const LUNGE := MapMotion.EVENT_STEP

var _losses := FightLosses.new()
var _pace := FightPace.new(1.0, 2)
var _rounds: Array[Vector2i] = [Vector2i(7, 2), Vector2i(0, 4)]


func after_each() -> void:
	_losses.free()


func _show(t: float) -> void:
	_losses.show_at(t, _pace, _rounds, Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, 1.0))


func test_nothing_shows_before_a_round() -> void:
	_show(0.5)
	assert_false(_losses.dealt.visible)
	assert_false(_losses.taken.visible)


func test_a_round_shows_what_each_side_lost_over_each() -> void:
	_show(_pace.hit_at(0) + 0.02)
	assert_eq(_losses.dealt.text, "−7")
	assert_eq(_losses.taken.text, "−2")
	assert_true(_losses.dealt.position.x > 0.99 and _losses.taken.position.z > 0.99)


func test_a_side_that_lost_nothing_shows_nothing() -> void:
	_show(_pace.hit_at(1) + 0.02)
	assert_false(_losses.dealt.visible)
	assert_eq(_losses.taken.text, "−4")


func test_they_go_when_the_round_has_faded() -> void:
	_show(_pace.hit_at(1) + 5.0)
	assert_false(_losses.taken.visible)

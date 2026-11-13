extends TestCase
## A creature swimming round a place.

const TURTLE := preload("res://assets/models/map_turtle.glb")
const JELLY := preload("res://assets/models/map_jelly.glb")

var _lap: CreatureLap


func before_each() -> void:
	_lap = CreatureLap.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_lap)


func after_each() -> void:
	_lap.free()


func test_has_no_creature_until_one_swims() -> void:
	_lap.advance(1.0)
	assert_null(_lap.creature)
	assert_eq(_lap.get_child_count(), 0)


func test_swims_round_an_ellipse_at_its_height() -> void:
	_lap.swim(TURTLE, Vector2(6.0, 4.0), 1.5, 40.0)
	assert_eq(_lap.creature.position, Vector3(6.0, 1.5, 0.0))
	_lap.advance(10.0)
	assert_almost_eq(_lap.creature.position.x, 0.0, 1e-4)
	assert_almost_eq(_lap.creature.position.z, 4.0, 1e-4)
	_lap.advance(30.0)
	assert_almost_eq(_lap.creature.position.x, 6.0, 1e-4)


func test_faces_where_it_goes_and_plays_its_swim() -> void:
	_lap.swim(TURTLE, Vector2(6.0, 6.0), 0.0, 40.0)
	_lap.advance(10.0)
	var forward := _lap.creature.transform.basis * Vector3.FORWARD
	assert_true(forward.x < -0.99)
	assert_true(ModelAnimator.new(_lap.creature).has_animation(&"swim"))


func test_another_creature_takes_the_place_of_the_first_where_it_was() -> void:
	_lap.swim(TURTLE, Vector2.ONE, 0.0, 10.0)
	var first := _lap.creature
	_lap.advance(2.5)
	_lap.swim(JELLY, Vector2.ONE, 0.0, 10.0)
	assert_false(is_instance_valid(first))
	assert_almost_eq(_lap.creature.position.z, 1.0, 1e-4, "a quarter of the lap on")
	assert_eq(_player().current_animation, "swim")
	_lap._process(0.5)
	assert_eq(_lap.get_child_count(), 1)


func test_the_same_creature_again_keeps_swimming_where_it_is() -> void:
	_lap.swim(TURTLE, Vector2(6.0, 4.0), 0.0, 40.0)
	var first := _lap.creature
	_lap.advance(10.0)
	_player().advance(0.25)
	var stroke := _player().current_animation_position
	assert_true(stroke > 0.0)
	_lap.swim(TURTLE, Vector2(6.0, 4.0), 0.0, 40.0)
	assert_eq(_lap.creature, first, "no new one")
	assert_almost_eq(first.position.z, 4.0, 1e-4, "nor back at the start of its lap")
	assert_eq(_player().current_animation, "swim")
	assert_eq(_player().current_animation_position, stroke, "its stroke goes on")


func test_the_same_creature_takes_to_another_ellipse_without_a_new_one() -> void:
	_lap.swim(TURTLE, Vector2(6.0, 4.0), 0.0, 40.0)
	var first := _lap.creature
	_lap.advance(10.0)
	_lap.swim(TURTLE, Vector2(8.0, 5.0), 1.5, 80.0)
	assert_eq(_lap.creature, first)
	assert_true(first.position.is_equal_approx(Vector3(0.0, 1.5, 5.0)))
	_lap.advance(20.0)
	assert_almost_eq(first.position.x, -8.0, 1e-4, "a lap twice as long")


## The player of the creature's animations.
func _player() -> AnimationPlayer:
	return _lap.creature.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer

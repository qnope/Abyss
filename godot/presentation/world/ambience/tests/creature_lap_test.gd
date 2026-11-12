extends TestCase
## A creature swimming round a place.

const TURTLE := preload("res://assets/models/map_turtle.glb")

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


func test_another_creature_takes_the_place_of_the_first() -> void:
	_lap.swim(TURTLE, Vector2.ONE, 0.0, 10.0)
	var first := _lap.creature
	_lap.swim(TURTLE, Vector2.ONE, 0.0, 10.0)
	assert_ne(_lap.creature, first)
	_lap._process(0.5)
	assert_eq(_lap.get_child_count(), 1)

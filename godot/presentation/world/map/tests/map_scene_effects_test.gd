extends MapTestCase
## What the map plays over a level: the fog lifting from the cells a scout has
## just seen, the camera shaken by a blow.

var _scene: MapScene


func before_each() -> void:
	_scene = mounted(MapScene.new()) as MapScene


func _level(seen: Array[Vector2i]) -> MapLevelState:
	var state := level_of(8, 8, seen)
	put(state, 2, 2, Content.RESOURCE_BONUS)
	return state


func test_a_level_shown_for_the_first_time_lifts_no_fog() -> void:
	_scene.show_level(_level([Vector2i(1, 1)]))
	assert_false(_scene.effects.is_playing())


func test_the_cells_a_scout_has_seen_since_lift_their_fog() -> void:
	_scene.show_level(_level([Vector2i(1, 1)]))
	_scene.show_level(_level([Vector2i(1, 1), Vector2i(2, 2), Vector2i(2, 1)]))
	var lift: FogLift = _scene.effects.current
	assert_not_null(lift)
	assert_eq(lift.get_parent(), _scene.effects)
	assert_false(_scene.contents.by_cell[Vector2i(2, 2)].visible, "under the fog meanwhile")
	_scene.effects._process(lift.duration())
	assert_false(_scene.effects.is_playing())
	assert_true(_scene.contents.by_cell[Vector2i(2, 2)].visible)
	assert_eq(_scene.fog.counts.values().reduce(func(a: int, b: int) -> int: return a + b, 0),
		MapFog.clouded(MapLooks.of(_level([Vector2i(1, 1), Vector2i(2, 2), Vector2i(2, 1)])), 8, 8).size(),
		"the shroud no longer covers them")


func test_the_scout_whose_exploration_is_over_leaves_with_the_fog() -> void:
	var before := _level([Vector2i(1, 1)])
	before.pending[Vector2i(2, 2)] = Vector2i(0, 0)
	_scene.show_level(before)
	_scene.show_level(_level([Vector2i(1, 1), Vector2i(2, 2)]))
	var lift: FogLift = _scene.effects.current
	assert_eq(lift.scouts.size(), 1)
	assert_true(_scene.scouts.tokens.is_empty(), "the map's own token is gone")


func test_a_scout_still_on_its_way_lifts_nothing_for_it() -> void:
	var state := _level([Vector2i(1, 1)])
	state.pending[Vector2i(5, 5)] = Vector2i(0, 0)
	_scene.show_level(state)
	var next := _level([Vector2i(1, 1), Vector2i(2, 2)])
	next.pending[Vector2i(5, 5)] = Vector2i(0, 0)
	_scene.show_level(next)
	assert_eq((_scene.effects.current as FogLift).scouts.size(), 0)


func test_drawing_the_level_again_ends_the_lift_at_once() -> void:
	_scene.show_level(_level([Vector2i(1, 1)]))
	var more := _level([Vector2i(1, 1), Vector2i(2, 2)])
	_scene.show_level(more)
	var lift: FogLift = _scene.effects.current
	_scene.show_level(more)
	assert_true(lift.is_done)
	assert_false(_scene.effects.is_playing())


func test_a_game_forgotten_lifts_no_fog_for_the_next() -> void:
	_scene.show_level(_level([Vector2i(1, 1)]))
	_scene.forget()
	_scene.show_level(_level([Vector2i(1, 1), Vector2i(2, 2)]))
	assert_false(_scene.effects.is_playing())


func test_a_blow_shakes_the_camera_to_the_side_and_it_rests_after() -> void:
	_scene.effects.jolted.emit(0.07)
	assert_almost_eq(_scene.camera.h_offset, 0.07, 1e-6)
	_scene.effects.jolted.emit(0.0)
	assert_eq(_scene.camera.h_offset, 0.0)

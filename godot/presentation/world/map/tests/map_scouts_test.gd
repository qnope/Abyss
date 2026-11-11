extends MapTestCase
## The scouts in transit: a token over each target, one just sent swims there,
## the ones already on their way wait (scout_token_layer_test.dart).

var _scouts: MapScouts


func before_each() -> void:
	_scouts = mounted(MapScouts.new()) as MapScouts


func _pending(targets: Array[Vector2i]) -> Dictionary[Vector2i, Vector2i]:
	var found: Dictionary[Vector2i, Vector2i] = {}
	for target in targets:
		found[target] = Vector2i(0, 0)
	return found


func test_the_scouts_already_sent_when_the_level_appears_wait_at_their_target() -> void:
	_scouts.show_scouts(_pending([Vector2i(3, 3)]), 1, 6, 6)
	var token := _scouts.tokens[Vector2i(3, 3)]
	assert_false(token.is_swimming())
	assert_eq(token.position, MapGrid.at(3, 3, 6, 6) + Vector3.UP * ScoutToken.HOVER)
	assert_false(_scouts.is_processing())


func test_a_scout_just_sent_swims_from_its_origin_to_its_target() -> void:
	_scouts.show_scouts({}, 1, 6, 6)
	_scouts.show_scouts({Vector2i(3, 3): Vector2i(0, 0)}, 1, 6, 6)
	var token := _scouts.tokens[Vector2i(3, 3)]
	assert_true(token.is_swimming())
	assert_eq(token.position, MapGrid.at(0, 0, 6, 6) + Vector3.UP * ScoutToken.HOVER)
	assert_true(_scouts.is_processing())
	_scouts._process(ScoutToken.SWIM / 2.0)
	assert_almost_eq(token.position.x, (MapGrid.at(0, 0, 6, 6).x + MapGrid.at(3, 3, 6, 6).x) / 2.0, 1e-4)
	assert_true(_scouts.is_processing())
	_scouts._process(ScoutToken.SWIM)
	assert_false(token.is_swimming())
	assert_eq(token.position, MapGrid.at(3, 3, 6, 6) + Vector3.UP * ScoutToken.HOVER)
	assert_false(_scouts.is_processing())


func test_a_scout_whose_exploration_is_over_leaves_at_once() -> void:
	_scouts.show_scouts(_pending([Vector2i(3, 3), Vector2i(4, 4)]), 1, 6, 6)
	var stays := _scouts.tokens[Vector2i(4, 4)]
	_scouts.show_scouts(_pending([Vector2i(4, 4)]), 1, 6, 6)
	assert_eq(_scouts.tokens.keys(), [Vector2i(4, 4)])
	assert_eq(_scouts.tokens[Vector2i(4, 4)], stays)
	assert_eq(_scouts.get_child_count(), 1)


func test_another_level_shows_its_scouts_at_rest() -> void:
	_scouts.show_scouts(_pending([Vector2i(3, 3)]), 1, 6, 6)
	var first := _scouts.tokens[Vector2i(3, 3)]
	_scouts.show_scouts(_pending([Vector2i(3, 3), Vector2i(1, 1)]), 2, 6, 6)
	assert_ne(_scouts.tokens[Vector2i(3, 3)], first, "the scouts of the first level are gone")
	assert_false(_scouts.tokens[Vector2i(1, 1)].is_swimming())
	assert_eq(_scouts.get_child_count(), 2)


func test_the_token_is_the_scout_unit() -> void:
	_scouts.show_scouts(_pending([Vector2i(3, 3)]), 1, 6, 6)
	var figure := _scouts.tokens[Vector2i(3, 3)].get_child(0)
	assert_true(figure is UnitStandIn)
	assert_eq((figure as UnitStandIn).type, UnitType.Value.SCOUT)

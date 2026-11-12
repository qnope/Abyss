extends MapTestCase
## The fog lifting from the cells a scout has just seen (map_fog_lift_test.dart,
## map_fog_lift_contents_test.dart): the clouds hold, then rise and fade while
## the wisps puff out; the contents of the cells show as the fog leaves them.

const SEEN: Array[Vector2i] = [Vector2i(1, 1), Vector2i(2, 1)]

var _state: MapLevelState
var _contents := MapContents.new()
var _lift: FogLift


func before_each() -> void:
	_state = level_of(6, 6, SEEN)
	put(_state, 1, 1, Content.RESOURCE_BONUS)
	_lift = _make(SEEN)


func after_each() -> void:
	_lift.free()
	_contents.free()


func _make(cells: Array[Vector2i], waited: Array[Vector2i] = []) -> FogLift:
	var looks := MapLooks.of(_state)
	_contents.show_looks(looks, 6, 6)
	return FogLift.new(cells, 6, 6, FogLifts.hidden(looks), _contents, waited)


func _clouds() -> int:
	var total := 0
	for layer in _lift.clouds:
		total += layer.multimesh.instance_count
	return total


func test_a_cloud_covers_each_cell_seen_in_a_layer_for_each_kind_of_cloud() -> void:
	assert_eq(_clouds(), 2)
	assert_true(_lift.clouds.size() <= 3)
	for layer in _lift.clouds:
		assert_eq(layer.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
		assert_not_null(layer.material_override)


func test_wisps_puff_out_from_the_edge_of_what_is_still_hidden() -> void:
	assert_true(_lift.wisps.size() > 0)
	for wisp in _lift.wisps:
		assert_eq(wisp.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
		assert_true(wisp.position.y > 0.0, "above the floor")


func test_a_wide_lift_keeps_its_wisps_to_a_few() -> void:
	var cells: Array[Vector2i] = []
	for y in range(1, 5):
		for x in range(1, 5):
			cells.append(Vector2i(x, y))
	_state = level_of(30, 30, cells)
	var looks := MapLooks.of(_state)
	var wide := FogLift.new(cells, 30, 30, FogLifts.hidden(looks), _contents, [])
	assert_true(wide.wisps.size() > 0)
	var many: Array[Vector2i] = []
	for y in range(1, 29):
		for x in range(1, 29):
			many.append(Vector2i(x, y))
	_state = level_of(30, 30, many)
	var huge := FogLift.new(many, 30, 30, FogLifts.hidden(MapLooks.of(_state)), _contents, [])
	assert_eq(huge.wisps.size(), FogLift.MAX_WISPS)
	wide.free()
	huge.free()


func test_the_fog_holds_then_lifts() -> void:
	assert_eq(_lift.duration(), FogLift.HOLD + FogLift.LIFT)
	assert_eq(_lift.opacity_at(0.0), 1.0)
	assert_eq(_lift.opacity_at(FogLift.HOLD), 1.0)
	assert_true(_lift.opacity_at(FogLift.HOLD + FogLift.LIFT / 2.0) < 1.0)
	assert_eq(_lift.opacity_at(_lift.duration()), 0.0)


func test_the_clouds_rise_and_fade_each_through_a_material_of_its_own() -> void:
	var murk := MapScenery.parts(MapScenery.FOG)[&"Cloud1"].surface_get_material(0) as StandardMaterial3D
	_lift.advance(FogLift.HOLD / 2.0)
	for layer in _lift.clouds:
		assert_eq(layer.position.y, 0.0, "they hold")
		assert_eq((layer.material_override as StandardMaterial3D).albedo_color.a, 1.0)
	_lift.advance(FogLift.HOLD / 2.0 + FogLift.LIFT / 2.0)
	for layer in _lift.clouds:
		assert_true(layer.position.y > 0.0)
		assert_true((layer.material_override as StandardMaterial3D).albedo_color.a < 1.0)
	_lift.finish()
	for layer in _lift.clouds:
		assert_eq((layer.material_override as StandardMaterial3D).albedo_color.a, 0.0)
		assert_ne(layer.material_override, murk, "the model's material is left alone")
	assert_eq(murk.albedo_color.a, 1.0)


func test_the_wisps_drift_off_and_swell() -> void:
	var home := _lift.wisps[0].position
	_lift.finish()
	assert_true(_lift.wisps[0].position.distance_to(home) > FogLift.DRIFT * 0.99)
	assert_true(_lift.wisps[0].scale.x > 1.0)


func test_the_contents_of_the_cells_show_as_the_fog_leaves_them() -> void:
	var treasure := _contents.by_cell[Vector2i(1, 1)]
	assert_false(treasure.visible, "hidden under the fog")
	_lift.advance(FogLift.HOLD / 2.0)
	assert_false(treasure.visible)
	_lift.advance(FogLift.HOLD)
	assert_true(treasure.visible, "shown as it lifts")


func test_an_effect_that_never_plays_leaves_the_contents_shown() -> void:
	_lift.finish()
	assert_true(_contents.by_cell[Vector2i(1, 1)].visible)


func test_the_scouts_that_waited_on_the_cells_leave_with_the_fog() -> void:
	var scouted := _make(SEEN, [Vector2i(2, 1)])
	assert_eq(scouted.scouts.size(), 1)
	var scout := scouted.scouts[0]
	assert_eq(scout.get_parent(), scouted)
	var waiting := scout.scale.x
	scouted.advance(FogLift.HOLD + FogLift.LIFT / 2.0)
	assert_true(scout.scale.x < waiting)
	scouted.finish()
	assert_eq(scout.gone, 1.0)
	scouted.free()

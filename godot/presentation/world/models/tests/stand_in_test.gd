extends TestCase
## A stand-in: its solid in its colour on the pad, taller with the tier,
## grey when degraded.

const Type := BuildingType.Value

var _stand_in: StandIn


func after_each() -> void:
	if _stand_in != null:
		_stand_in.free()


func test_stands_its_solid_on_the_pad() -> void:
	_stand_in = StandIn.new(Type.CORAL_CITADEL)
	var box := _stand_in.body.mesh.get_aabb()
	var bottom := _stand_in.body.position.y + box.position.y
	assert_almost_eq(bottom, 0.0, 1e-4)
	assert_eq(_stand_in.get_child_count(), 1)


func test_has_the_colour_of_its_building() -> void:
	for type: BuildingType.Value in BuildingType.Value.values():
		var stand_in := StandIn.new(type, 2)
		var material := stand_in.body.material_override as StandardMaterial3D
		assert_eq(material.albedo_color, WorldPalette.of(type), str(type))
		assert_true(material.emission_enabled)
		stand_in.free()


func test_rises_with_its_tier() -> void:
	var expected: Dictionary[int, float] = {1: 1.0, 3: 1.0, 4: 1.3, 7: 1.3, 8: 1.6}
	for level: int in expected:
		var stand_in := StandIn.new(Type.LABORATORY, level)
		assert_almost_eq(stand_in.scale.y, expected[level], 1e-5, str(level))
		stand_in.free()


func test_a_plot_is_drawn_at_the_first_tier() -> void:
	_stand_in = StandIn.new(Type.LABORATORY, 0)
	assert_eq(_stand_in.scale.y, 1.0)


func test_a_degraded_building_is_grey_and_does_not_glow() -> void:
	_stand_in = StandIn.new(Type.BARRACKS, 3, true)
	var material := _stand_in.body.material_override as StandardMaterial3D
	assert_eq(material.albedo_color, WorldPalette.DEGRADED)
	assert_false(material.emission_enabled)
	assert_true(_stand_in.degraded)

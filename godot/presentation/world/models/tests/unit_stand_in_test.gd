extends TestCase
## A unit's stand-in: its solid in its colour on the floor, a grey ghost when
## the unit is locked.

const Type := UnitType.Value

var _stand_in: UnitStandIn


func after_each() -> void:
	if _stand_in != null:
		_stand_in.free()


func test_stands_its_solid_on_the_floor() -> void:
	for type: UnitType.Value in Type.values():
		_stand_in = UnitStandIn.new(type)
		var box := _stand_in.body.mesh.get_aabb()
		assert_almost_eq(_stand_in.body.position.y + box.position.y, 0.0, 1e-4, str(type))
		assert_eq(_stand_in.get_child_count(), 1)
		_stand_in.free()
	_stand_in = null


func test_has_the_colour_of_its_unit() -> void:
	for type: UnitType.Value in Type.values():
		var stand_in := UnitStandIn.new(type)
		var material := stand_in.body.material_override as StandardMaterial3D
		assert_eq(material.albedo_color, WorldPalette.unit(type), str(type))
		assert_true(material.emission_enabled)
		assert_eq(material.transparency, BaseMaterial3D.TRANSPARENCY_DISABLED)
		stand_in.free()


func test_a_locked_unit_is_a_grey_ghost_that_does_not_glow() -> void:
	_stand_in = UnitStandIn.new(Type.GUARDIAN, true)
	var material := _stand_in.body.material_override as StandardMaterial3D
	assert_eq(material.albedo_color, Color(WorldPalette.DEGRADED, WorldPalette.GHOST_OPACITY))
	assert_eq(material.transparency, BaseMaterial3D.TRANSPARENCY_ALPHA)
	assert_false(material.emission_enabled)
	assert_true(_stand_in.ghost)

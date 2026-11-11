extends TestCase
## The solids the six units are until their models exist: one figure each,
## told apart by its kind of solid.

const Type := UnitType.Value
## A figure stands in a squad on a drill pad under 3 metres wide.
const MAX_WIDTH := 1.0
const MAX_HEIGHT := 1.7


func test_each_unit_has_a_kind_of_solid_of_its_own() -> void:
	var seen: Dictionary[StandInShape.Kind, UnitType.Value] = {}
	for type: UnitType.Value in Type.values():
		var kind := StandInShape.of_unit(type).kind
		assert_false(seen.has(kind), "%s has the solid of another" % type)
		seen[kind] = type
	assert_eq(seen.size(), 6)


func test_a_figure_is_smaller_than_a_pad() -> void:
	for type: UnitType.Value in Type.values():
		var size := StandInShape.of_unit(type).size
		assert_true(size.x <= MAX_WIDTH and size.z <= MAX_WIDTH, str(type))
		assert_true(size.y <= MAX_HEIGHT, str(type))


func test_each_mesh_is_the_size_of_its_box() -> void:
	for type: UnitType.Value in Type.values():
		var shape := StandInShape.of_unit(type)
		var box := shape.mesh().get_aabb()
		assert_almost_eq(box.size.y, shape.size.y, 0.01, str(type))
		assert_almost_eq(box.size.x, shape.size.x, 0.01, str(type))

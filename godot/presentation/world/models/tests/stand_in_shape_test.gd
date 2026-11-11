extends TestCase
## The solids the eleven buildings are until their models exist.

const Kind := StandInShape.Kind
## A pad is 1.88 wide, the headquarters' 2.88.
const PAD := 1.88
const HEADQUARTERS_PAD := 2.88


func test_each_building_has_a_shape_of_its_own() -> void:
	var seen: Dictionary[String, BuildingType.Value] = {}
	for type: BuildingType.Value in BuildingType.Value.values():
		var shape := StandInShape.of(type)
		var signature := "%s %s %f" % [shape.kind, shape.size, shape.taper]
		assert_false(seen.has(signature), "%s has the shape of another" % type)
		seen[signature] = type
	assert_eq(seen.size(), 11)


func test_the_solids_fit_their_pads() -> void:
	for type: BuildingType.Value in BuildingType.Value.values():
		var width := StandInShape.of(type).size.x
		var pad := HEADQUARTERS_PAD if type == BuildingType.Value.HEADQUARTERS else PAD
		assert_true(width <= pad and StandInShape.of(type).size.z <= pad, str(type))


func test_uses_every_kind_of_primitive() -> void:
	var kinds: Dictionary[StandInShape.Kind, bool] = {}
	for type: BuildingType.Value in BuildingType.Value.values():
		kinds[StandInShape.of(type).kind] = true
	assert_eq(kinds.size(), Kind.size())


func test_each_mesh_is_the_size_of_its_box() -> void:
	for type: BuildingType.Value in BuildingType.Value.values():
		var shape := StandInShape.of(type)
		var box := shape.mesh().get_aabb()
		assert_almost_eq(box.size.y, shape.size.y, 0.01, str(type))
		assert_almost_eq(box.size.x, shape.size.x, 0.01, str(type))
		assert_almost_eq(box.get_center().y, 0.0, 0.01, str(type))


func test_makes_the_mesh_of_each_kind() -> void:
	assert_true(StandInShape.new(Kind.BOX, Vector3.ONE).mesh() is BoxMesh)
	assert_true(StandInShape.new(Kind.CYLINDER, Vector3.ONE, 0.5).mesh() is CylinderMesh)
	assert_true(StandInShape.new(Kind.PRISM, Vector3.ONE).mesh() is PrismMesh)
	assert_true(StandInShape.new(Kind.CAPSULE, Vector3(0.5, 1.0, 0.5)).mesh() is CapsuleMesh)
	assert_true(StandInShape.new(Kind.TORUS, Vector3(1.0, 0.4, 1.0)).mesh() is TorusMesh)
	assert_true(StandInShape.new(Kind.SPHERE, Vector3.ONE).mesh() is SphereMesh)
	var cone := StandInShape.new(Kind.CYLINDER, Vector3(2.0, 1.0, 2.0), 0.5).mesh() as CylinderMesh
	assert_eq([cone.bottom_radius, cone.top_radius], [1.0, 0.5])

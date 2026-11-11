extends TestCase
## Where a building ends, model or stand-in.

var _root: Node3D


func before_each() -> void:
	_root = Node3D.new()


func after_each() -> void:
	_root.free()


func test_a_node_without_a_mesh_ends_at_the_ground() -> void:
	assert_eq(ModelBounds.top_of(_root), 0.0)


func test_finds_the_top_of_a_nested_mesh_in_the_space_of_the_parent() -> void:
	_root.position = Vector3(1.0, 0.5, 2.0)
	var part := Node3D.new()
	part.position.y = 1.0
	var mesh := MeshInstance3D.new()
	mesh.mesh = BoxMesh.new()
	part.add_child(mesh)
	_root.add_child(part)
	assert_almost_eq(ModelBounds.top_of(_root), 2.0, 1e-4)


func test_the_highest_of_several_meshes_counts() -> void:
	for height: float in [1.0, 3.0, 2.0]:
		var mesh := MeshInstance3D.new()
		mesh.mesh = BoxMesh.new()
		mesh.position.y = height
		_root.add_child(mesh)
	assert_almost_eq(ModelBounds.top_of(_root), 3.5, 1e-4)


func test_a_mesh_node_with_no_mesh_is_skipped() -> void:
	_root.add_child(MeshInstance3D.new())
	assert_eq(ModelBounds.top_of(_root), 0.0)


func test_a_stand_in_ends_at_its_height() -> void:
	var stand_in := StandIn.new(BuildingType.Value.CORAL_CITADEL, 4)
	_root.add_child(stand_in)
	assert_almost_eq(ModelBounds.top_of(stand_in), 1.9 * 1.3, 1e-3)
	assert_almost_eq(ModelBounds.top_of(_root), 1.9 * 1.3, 1e-3)

extends TestCase
## The floor of the review board's grid: a MultiMesh for each variant of a
## level's tiles laid on every cell, and the fog's tiles beyond the seen patch.

const GridFloor := preload("res://tool/models/grid_floor.gd")
const GridInstances := preload("res://tool/models/grid_instances.gd")
const GridLayout := preload("res://tool/models/grid_layout.gd")

var _floor: Node3D


func after_each() -> void:
	if _floor != null:
		_floor.free()
		_floor = null


func test_every_cell_of_a_board_all_seen_has_a_lit_tile() -> void:
	_floor = GridFloor.build(1, 10, false)
	assert_eq(_instances("Lit"), 100)
	assert_eq(_instances("Fog"), 0)


func test_a_fogged_board_has_lit_tiles_on_the_patch_and_the_fogs_elsewhere() -> void:
	_floor = GridFloor.build(2, 10, true)
	var seen := 0
	for y in 10:
		for x in 10:
			if GridLayout.seen(x, y, 10):
				seen += 1
	assert_eq(_instances("Lit"), seen)
	assert_eq(_instances("Fog"), 100 - seen)


func test_the_multimeshes_are_named_after_their_variants() -> void:
	_floor = GridFloor.build(3, 6, false)
	for child in _floor.get_children():
		if child is MultiMeshInstance3D and (String(child.name)).begins_with("Lit"):
			assert_true((child as MultiMeshInstance3D).multimesh.instance_count > 0)


func test_the_instances_helper_lays_a_mesh_in_each_place() -> void:
	var places: Array[Transform3D] = [Transform3D(Basis.IDENTITY, Vector3.ONE), Transform3D.IDENTITY]
	var instance := GridInstances.multi(BoxMesh.new(), places, "Box")
	assert_eq(instance.name, &"Box")
	assert_eq(instance.multimesh.instance_count, 2)
	instance.free()
	var unnamed := GridInstances.multi(BoxMesh.new(), places)
	assert_ne(unnamed.name, &"Box")
	unnamed.free()


func test_the_meshes_of_numbered_nodes() -> void:
	var model := Node3D.new()
	for node_name: String in ["Lit1", "Lit2", "Lit4", "Fog1"]:
		var node := MeshInstance3D.new()
		node.name = node_name
		node.mesh = BoxMesh.new()
		model.add_child(node)
	assert_eq(GridInstances.meshes(model, "Lit").size(), 3)
	assert_eq(GridInstances.meshes(model, "Fog").size(), 1)
	assert_eq(GridInstances.meshes(model, "Cloud").size(), 0)
	model.free()


func _instances(prefix: String) -> int:
	var total := 0
	for child in _floor.get_children():
		if child is MultiMeshInstance3D and String(child.name).begins_with(prefix):
			total += (child as MultiMeshInstance3D).multimesh.instance_count
	return total

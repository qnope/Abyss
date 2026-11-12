extends TestCase
## The backdrop round the review board's grid: where the repeated pieces go.

const GridBackdrop := preload("res://tool/models/grid_backdrop.gd")

var _floor: Node3D
var _scene: Node3D


func after_each() -> void:
	for node: Node in [_floor, _scene]:
		if node != null:
			node.free()
	_floor = null
	_scene = null


func test_edge_pieces_line_each_side_with_their_front_turned_outward() -> void:
	var places := GridBackdrop.places(10, "Edge")
	assert_eq(places.size(), 20)
	for at in places:
		var out := at.basis * Vector3.BACK
		assert_almost_eq(at.origin.dot(out), 5.0, 0.001, "on the edge of the board")
	var south := places[0]
	assert_true(south.basis.is_equal_approx(Basis.IDENTITY))
	assert_almost_eq(south.origin.x, -4.0, 0.001)
	assert_almost_eq(places[4].origin.x, 4.0, 0.001)


func test_a_corner_stands_at_each_corner() -> void:
	var places := GridBackdrop.places(10, "Corner")
	assert_eq(places.size(), 4)
	var corners := {}
	for at in places:
		assert_almost_eq(absf(at.origin.x), 5.0, 0.001)
		assert_almost_eq(absf(at.origin.z), 5.0, 0.001)
		corners[Vector2(at.origin.x, at.origin.z)] = true
	assert_eq(corners.size(), 4)


func test_dresses_a_board_with_the_pieces_and_the_silhouettes_of_a_model() -> void:
	_scene = Node3D.new()
	for piece_name: String in ["Edge1", "Edge2", "Corner", "Whale", "Kelp"]:
		var piece := MeshInstance3D.new()
		piece.name = piece_name
		piece.mesh = BoxMesh.new()
		_scene.add_child(piece)
	_floor = Node3D.new()
	GridBackdrop.dress(_floor, _scene, 10)
	assert_eq(_floor.get_child_count(), 20 + 4 + 2)
	var far := _floor.get_child(24) as MeshInstance3D
	assert_eq(far.mesh, (_scene.get_node("Whale") as MeshInstance3D).mesh)
	assert_true(far.position.z < -5.0, "beyond the far rim")

extends TestCase
## The box of a model for the renders of tool/models: its own, or, for a
## creature the renders turned to the camera, the one round the turned model.

const ModelBounds := preload("res://tool/models/model_bounds.gd")

var _model: Node3D


func before_each() -> void:
	_model = Node3D.new()
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(2.0, 1.0, 0.5)
	mesh.mesh = box
	_model.add_child(mesh)


func after_each() -> void:
	_model.free()


func test_the_box_of_a_model_is_its_meshs() -> void:
	var bounds := ModelBounds.of(_model)
	assert_true(bounds.size.is_equal_approx(Vector3(2.0, 1.0, 0.5)))


func test_a_turned_model_keeps_its_own_box_until_asked_for_the_turned_one() -> void:
	_model.rotation_degrees.y = 90.0
	assert_true(ModelBounds.of(_model).size.is_equal_approx(Vector3(2.0, 1.0, 0.5)))
	var turned := ModelBounds.of(_model, true)
	assert_true(turned.size.is_equal_approx(Vector3(0.5, 1.0, 2.0)))


func test_a_turn_of_an_eighth_is_boxed_round_its_vertices_not_its_box() -> void:
	_model.rotation_degrees.y = 45.0
	var turned := ModelBounds.of(_model, true)
	# A box of 2 x 0.5 turned 45 degrees spans (2 + 0.5) / sqrt 2, not 2 x 2.
	assert_almost_eq(turned.size.x, 2.5 / sqrt(2.0), 0.001)
	assert_almost_eq(turned.size.z, 2.5 / sqrt(2.0), 0.001)

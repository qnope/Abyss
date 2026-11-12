extends TestCase
## The renders turn a creature (a model with a rig) to the camera, and leave a
## building as it is.

const ModelFacing := preload("res://tool/models/model_facing.gd")

var _model: Node3D


func after_each() -> void:
	if _model != null:
		_model.free()
		_model = null


func _with(children: Array[String]) -> Node3D:
	_model = Node3D.new()
	for name_ in children:
		var child := Node3D.new()
		child.name = name_
		_model.add_child(child)
	return _model


func test_a_model_with_a_rig_is_a_creature() -> void:
	assert_true(ModelFacing.is_creature(_with(["Rig"])))


func test_a_model_without_a_rig_is_not() -> void:
	assert_false(ModelFacing.is_creature(_with(["Barracks"])))


func test_a_creature_is_turned_to_the_camera() -> void:
	ModelFacing.face(_with(["Rig"]), ModelFacing.GAME)
	assert_almost_eq(_model.rotation_degrees.y, -135.0, 0.001)
	# Its forward, -Z, then points at the game's camera: toward +x and +z.
	var forward := -_model.transform.basis.z
	assert_true(forward.x > 0.7 and forward.z > 0.7)


func test_a_building_is_left_as_it_is() -> void:
	ModelFacing.face(_with(["Barracks"]), ModelFacing.FRONT)
	assert_eq(_model.rotation_degrees.y, 0.0)

extends TestCase
## A building rendered with the island stands on the pad named after it;
## a model without a pad stays where it is.

const ModelPads := preload("res://tool/models/model_pads.gd")

var _group: Node3D


func after_each() -> void:
	_group.free()


func test_seats_a_building_on_the_pad_named_after_it() -> void:
	_group = Node3D.new()
	var island := _model("Island")
	var pads := Node3D.new()
	pads.name = "Pads"
	island.add_child(pads)
	var pad := Node3D.new()
	pad.name = "Headquarters"
	pad.position = Vector3(0.4, 0.12, 0.4)
	pads.add_child(pad)
	var building := _model("Headquarters")
	var other := _model("Swatches")
	ModelPads.seat(_group)
	assert_eq(building.position, Vector3(0.4, 0.12, 0.4))
	assert_eq(other.position, Vector3.ZERO)
	assert_eq(island.position, Vector3.ZERO)


func _model(root_name: String) -> Node3D:
	var model := Node3D.new()
	var root := Node3D.new()
	root.name = root_name
	model.add_child(root)
	_group.add_child(model)
	return model

extends TestCase
## A model's tiers are the nodes Tier<N>, wherever they stand in it.

const ModelTiers := preload("res://tool/models/model_tiers.gd")

var _model: Node3D


func before_each() -> void:
	_model = Node3D.new()
	var building := _node("Building", _model)
	_node("Tier1", building)
	_node("Tier2", building)
	var array := _node("Array", building)
	_node("Tier3", array)
	_node("Tiers", array)
	_node("Tier", array)


func after_each() -> void:
	_model.free()


func test_reads_the_number_of_a_tier() -> void:
	assert_eq(ModelTiers.number("Tier2"), 2)
	assert_eq(ModelTiers.number("Tier"), 0)
	assert_eq(ModelTiers.number("Tiers"), 0)
	assert_eq(ModelTiers.number("Array"), 0)


func test_counts_the_highest_tier_even_when_nested() -> void:
	assert_eq(ModelTiers.count(_model), 3)
	var empty := Node3D.new()
	assert_eq(ModelTiers.count(empty), 0)
	empty.free()


func test_hides_the_tiers_above_the_one_asked_and_nothing_else() -> void:
	ModelTiers.show_up_to(_model, 2)
	assert_true(_find("Tier1").visible)
	assert_true(_find("Tier2").visible)
	assert_false(_find("Tier3").visible)
	assert_true(_find("Tiers").visible)
	assert_true(_find("Array").visible)
	ModelTiers.show_up_to(_model, 3)
	assert_true(_find("Tier3").visible)


func _node(node_name: String, parent: Node) -> Node3D:
	var node := Node3D.new()
	node.name = node_name
	parent.add_child(node)
	return node


func _find(node_name: String) -> Node3D:
	return _model.find_child(node_name, true, false) as Node3D

extends TestCase
## The one place that chooses between a model and a stand-in.

const Type := BuildingType.Value

var _made: Array[Node3D] = []


func after_each() -> void:
	for node in _made:
		node.free()


func test_has_a_model_for_the_three_buildings_that_have_one() -> void:
	var with_model: Array[BuildingType.Value] = []
	for type: BuildingType.Value in BuildingType.Value.values():
		if WorldModels.has_model(type):
			with_model.append(type)
	assert_eq(with_model, [Type.HEADQUARTERS, Type.SOLAR_PANEL, Type.CORAL_CITADEL] as Array[BuildingType.Value])


func test_gives_the_model_when_there_is_one() -> void:
	var node := _make(Type.HEADQUARTERS, 3)
	assert_false(node is StandIn)
	assert_not_null(node.get_node("Headquarters/Beacon"))


func test_gives_a_stand_in_when_there_is_none() -> void:
	for type: BuildingType.Value in BuildingType.Value.values():
		if not WorldModels.has_model(type):
			var node := _make(type, 2)
			assert_true(node is StandIn, str(type))
			assert_eq((node as StandIn).type, type)


func test_the_stand_in_can_be_asked_for_whatever_the_building() -> void:
	var node := WorldModels.building(Type.HEADQUARTERS, 5, false, false)
	_made.append(node)
	assert_true(node is StandIn)
	var direct := WorldModels.stand_in(Type.SOLAR_PANEL, 2, true)
	_made.append(direct)
	assert_true(direct.degraded)
	assert_eq(direct.level, 2)


func test_hands_the_level_and_the_degradation_to_the_stand_in() -> void:
	var node := _make(Type.BARRACKS, 8, true) as StandIn
	assert_eq([node.level, node.degraded], [8, true])


func test_a_degraded_model_is_veiled_in_grey() -> void:
	var node := _make(Type.CORAL_CITADEL, 2, true)
	var meshes := node.find_children("*", "GeometryInstance3D", true, false)
	assert_false(meshes.is_empty())
	for mesh: Node in meshes:
		var veil := (mesh as GeometryInstance3D).material_overlay as StandardMaterial3D
		assert_eq(veil.albedo_color, Color(WorldPalette.DEGRADED, WorldModels.VEIL))
	var healthy := _make(Type.CORAL_CITADEL, 2)
	for mesh: Node in healthy.find_children("*", "GeometryInstance3D", true, false):
		assert_null((mesh as GeometryInstance3D).material_overlay)


func _make(type: BuildingType.Value, level: int, degraded := false) -> Node3D:
	var node := WorldModels.building(type, level, degraded)
	# In the tree, as the base's buildings are: freed outside it, a node with
	# its own materials makes the renderer complain.
	(Engine.get_main_loop() as SceneTree).root.add_child(node)
	_made.append(node)
	return node


func test_gives_a_stand_in_for_every_unit_until_step_7() -> void:
	for type: UnitType.Value in UnitType.Value.values():
		var node := _unit(type)
		assert_true(node is UnitStandIn, str(type))
		assert_eq((node as UnitStandIn).type, type)
		assert_false((node as UnitStandIn).ghost)


func test_gives_the_ghost_of_a_locked_unit() -> void:
	var node := _unit(UnitType.Value.GUARDIAN, true)
	assert_true((node as UnitStandIn).ghost)


func test_gives_the_model_of_a_unit_when_there_is_one() -> void:
	var models: Dictionary[UnitType.Value, PackedScene] = {
		UnitType.Value.SCOUT: WorldModels.MODELS[BuildingType.Value.HEADQUARTERS],
	}
	var model := _unit(UnitType.Value.SCOUT, false, models)
	assert_false(model is UnitStandIn)
	for mesh: Node in model.find_children("*", "GeometryInstance3D", true, false):
		assert_null((mesh as GeometryInstance3D).material_overlay)
	var ghost := _unit(UnitType.Value.SCOUT, true, models)
	for mesh: Node in ghost.find_children("*", "GeometryInstance3D", true, false):
		assert_not_null((mesh as GeometryInstance3D).material_overlay)
	assert_true(_unit(UnitType.Value.GUARDIAN, false, models) is UnitStandIn, "the others stay stand-ins")


func _unit(type: UnitType.Value, ghost := false,
		models: Dictionary[UnitType.Value, PackedScene] = WorldModels.UNIT_MODELS) -> Node3D:
	var node := WorldModels.unit(type, ghost, models)
	(Engine.get_main_loop() as SceneTree).root.add_child(node)
	_made.append(node)
	return node

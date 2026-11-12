extends TestCase
## A squad on its drill pad: figures by tier, the plaque, the signs.

const Type := UnitType.Value

var _squad: Squad


func before_each() -> void:
	_squad = Squad.new(Type.HARPOONIST)
	(Engine.get_main_loop() as SceneTree).root.add_child(_squad)


func after_each() -> void:
	_squad.free()


func _marks() -> Array[PadMark]:
	var found: Array[PadMark] = []
	for mark: Node in _squad.marks.get_children():
		found.append(mark as PadMark)
	return found


func test_stands_on_the_pad_of_its_unit() -> void:
	assert_eq(_squad.position, ParadeLayout.pad_of(Type.HARPOONIST))
	assert_not_null(_squad.get_node("Pad"))


func test_stands_as_many_figures_as_the_count_tier() -> void:
	for count: int in [0, 1, 2, 6, 16, 31, 61, 500]:
		_squad.show_state(SquadState.new(Type.HARPOONIST, count))
		assert_eq(_squad.figures.get_child_count(), SquadSize.of(count), "%d units" % count)


func test_the_figures_are_the_models_of_the_unit_on_their_slots() -> void:
	_squad.show_state(SquadState.new(Type.HARPOONIST, 6))
	for index in 3:
		var figure := _squad.figures.get_child(index) as Node3D
		assert_eq(figure.scene_file_path, WorldModels.UNIT_MODELS[Type.HARPOONIST].resource_path)
		assert_not_null(WorldModels.animator(figure))
		assert_eq(figure.position.x, ParadeLayout.slot(index).x)
		assert_almost_eq(figure.position.y, Squad.PAD_HEIGHT, 1e-5)


func test_a_locked_squad_is_one_ghost_and_a_padlock() -> void:
	_squad.show_state(SquadState.new(Type.HARPOONIST, 40, true, false, "Caserne niv. 3"))
	assert_eq(_squad.figures.get_child_count(), 1)
	var ghost := _squad.figures.get_child(0)
	for mesh: Node in ghost.find_children("*", "GeometryInstance3D", true, false):
		assert_not_null((mesh as GeometryInstance3D).material_overlay)
	assert_eq(_marks().size(), 1)
	assert_eq(_marks()[0].kind, PadMark.Kind.LOCKED)
	assert_eq(_squad.plaque.text, "Caserne niv. 3")
	assert_false((_squad.get_node("Ring") as MeshInstance3D).visible)


func test_a_squad_that_can_recruit_has_a_green_plus() -> void:
	_squad.show_state(SquadState.new(Type.HARPOONIST, 3, false, true, "Harponneurs"))
	assert_eq(_marks().size(), 1)
	assert_eq(_marks()[0].kind, PadMark.Kind.BUILD)
	assert_eq(_marks()[0].modulate, WorldPalette.UPGRADE)
	_squad.show_state(SquadState.new(Type.HARPOONIST, 3, false, false, "Harponneurs"))
	assert_eq(_marks().size(), 0, "the plus goes once it cannot recruit")


func test_writes_the_count_and_the_caption_in_the_colour_of_the_unit() -> void:
	_squad.show_state(SquadState.new(Type.HARPOONIST, 22, false, false, "Harponneurs"))
	assert_eq(_squad.plaque.text, "22\nHarponneurs")
	assert_eq(_squad.plaque.modulate, WorldPalette.unit(Type.HARPOONIST))
	assert_true((_squad.get_node("Ring") as MeshInstance3D).visible)


func test_writes_an_empty_squad_faintly() -> void:
	_squad.show_state(SquadState.new(Type.HARPOONIST, 0, false, false, "Harponneurs"))
	assert_eq(_squad.plaque.text, "0\nHarponneurs")
	assert_almost_eq(_squad.plaque.modulate.a, WorldPalette.EMPTY_SQUAD, 1e-5)


func test_is_picked_over_its_pad_up_to_its_reach() -> void:
	var box := _squad.box()
	assert_true(box.has_point(_squad.position + Vector3(0.0, 1.0, 0.0)))
	assert_false(box.has_point(_squad.position + Vector3(0.0, Squad.REACH + 0.5, 0.0)))
	assert_false(box.has_point(_squad.position + Vector3(2.0, 1.0, 0.0)))

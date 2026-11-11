extends TestCase
## The level and the signs over the pads.

const ISLAND := preload("res://assets/models/base_island.glb")
const Type := BuildingType.Value

var _island: Node3D
var _pads: BasePads
var _buildings: BaseBuildings
var _marks: PadMarks


func before_each() -> void:
	_island = ISLAND.instantiate() as Node3D
	_pads = BasePads.new(_island.get_node("Pads") as Node3D)
	_buildings = BaseBuildings.new()
	_marks = PadMarks.new()


func after_each() -> void:
	for node: Node in [_island, _buildings, _marks]:
		node.free()


func test_writes_the_level_over_a_building() -> void:
	_show([PadState.new(Type.BARRACKS, 4)])
	var label := _marks.get_child(0) as PadLevelLabel
	assert_eq(label.text, "4")
	var stand_in := _buildings.building(&"Barracks")
	var origin := _pads.origin_of(&"Barracks")
	assert_almost_eq(label.position.y, ModelBounds.top_of(stand_in) + PadMarks.LEVEL_GAP, 1e-4)
	assert_eq([label.position.x, label.position.z], [origin.x, origin.z])
	assert_eq(_marks.get_child_count(), 1, "no sign: it needs nothing")


func test_clears_a_model_too() -> void:
	_show([PadState.new(Type.HEADQUARTERS, 2)])
	var top := ModelBounds.top_of(_buildings.building(&"Headquarters"))
	assert_true(top > 3.0)
	assert_almost_eq((_marks.get_child(0) as Node3D).position.y, top + PadMarks.LEVEL_GAP, 1e-4)


func test_signs_a_building_that_can_rise() -> void:
	_show([PadState.new(Type.BARRACKS, 1, false, true)])
	assert_eq(_kinds(), [PadMark.Kind.UPGRADE] as Array[PadMark.Kind])
	var sign_ := _marks.get_child(1) as PadMark
	assert_true(sign_.position.y > (_marks.get_child(0) as Node3D).position.y)


func test_warns_of_a_degraded_building_before_anything_else() -> void:
	_show([PadState.new(Type.BARRACKS, 1, true, true)])
	assert_eq(_kinds(), [PadMark.Kind.DEGRADED] as Array[PadMark.Kind])


func test_marks_a_plot_that_can_be_built_on() -> void:
	_show([PadState.new(Type.BARRACKS, 0, false, true)])
	assert_eq(_kinds(), [PadMark.Kind.BUILD] as Array[PadMark.Kind])
	var origin := _pads.origin_of(&"Barracks")
	assert_almost_eq((_marks.get_child(0) as Node3D).position.y, origin.y + PadMarks.PLOT_HEIGHT, 1e-4)


func test_a_plot_held_back_shows_a_padlock_even_if_the_resources_are_there() -> void:
	_show([PadState.new(Type.BARRACKS, 0, false, true, true)])
	assert_eq(_kinds(), [PadMark.Kind.LOCKED] as Array[PadMark.Kind])


func test_a_plot_with_nothing_to_say_shows_nothing() -> void:
	_show([PadState.new(Type.BARRACKS)])
	assert_eq(_marks.get_child_count(), 0)


func test_draws_anew_with_each_change() -> void:
	_show([PadState.new(Type.BARRACKS, 1, false, true), PadState.new(Type.LABORATORY, 2)])
	_show([PadState.new(Type.LABORATORY, 2)])
	assert_eq(_marks.get_child_count(), 1)
	assert_eq((_marks.get_child(0) as PadLevelLabel).text, "2")


func _show(states: Array[PadState]) -> void:
	_buildings.build(states, _pads)
	_marks.show_marks(states, _pads, _buildings)


func _kinds() -> Array[PadMark.Kind]:
	var kinds: Array[PadMark.Kind] = []
	for child: Node in _marks.get_children():
		if child is PadMark:
			kinds.append((child as PadMark).kind)
	return kinds

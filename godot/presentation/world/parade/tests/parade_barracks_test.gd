extends TestCase
## The barracks at the back of the parade: the building at its level, or the
## plot to build.

const Type := BuildingType.Value

var _barracks: ParadeBarracks


func before_each() -> void:
	_barracks = ParadeBarracks.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_barracks)


func after_each() -> void:
	_barracks.free()


func _kinds() -> Array[PadMark.Kind]:
	var found: Array[PadMark.Kind] = []
	for child: Node in _barracks.get_children():
		if child is PadMark:
			found.append((child as PadMark).kind)
	return found


func test_stands_at_the_back_of_the_ground() -> void:
	assert_eq(_barracks.position, ParadeLayout.at(ParadeLayout.BARRACKS))


func test_a_built_barracks_stands_at_its_level() -> void:
	_barracks.show_state(PadState.new(Type.BARRACKS, 5))
	var stand_in := _barracks.building as StandIn
	assert_eq(stand_in.type, Type.BARRACKS)
	assert_eq(stand_in.level, 5)
	assert_false(_barracks.plot.visible)
	var level := _barracks.find_child("Level", false, false) as PadLevelLabel
	assert_eq(level.text, "5")
	assert_true(level.position.y > ModelBounds.top_of(stand_in))
	assert_eq(_kinds(), [] as Array[PadMark.Kind])


func test_a_degraded_barracks_is_grey_and_warned_of() -> void:
	_barracks.show_state(PadState.new(Type.BARRACKS, 2, true, true))
	assert_true((_barracks.building as StandIn).degraded)
	assert_eq(_kinds(), [PadMark.Kind.DEGRADED] as Array[PadMark.Kind])


func test_a_barracks_that_can_rise_has_an_arrow() -> void:
	_barracks.show_state(PadState.new(Type.BARRACKS, 2, false, true))
	assert_eq(_kinds(), [PadMark.Kind.UPGRADE] as Array[PadMark.Kind])


func test_the_plot_shows_a_plus_when_it_can_be_built_on() -> void:
	_barracks.show_state(PadState.new(Type.BARRACKS, 0, false, true))
	assert_null(_barracks.building)
	assert_true(_barracks.plot.visible)
	assert_eq(_kinds(), [PadMark.Kind.BUILD] as Array[PadMark.Kind])


func test_the_plot_shows_a_padlock_when_a_prerequisite_holds_it_back() -> void:
	_barracks.show_state(PadState.new(Type.BARRACKS, 0, false, false, true))
	assert_eq(_kinds(), [PadMark.Kind.LOCKED] as Array[PadMark.Kind])
	_barracks.show_state(PadState.new(Type.BARRACKS, 0))
	assert_eq(_kinds(), [] as Array[PadMark.Kind])


func test_the_building_replaces_the_plot_and_the_plot_the_building() -> void:
	_barracks.show_state(PadState.new(Type.BARRACKS, 1))
	var children := _barracks.get_child_count()
	_barracks.show_state(PadState.new(Type.BARRACKS, 2))
	assert_eq(_barracks.get_child_count(), children, "nothing piles up")
	_barracks.show_state(PadState.new(Type.BARRACKS, 0))
	assert_eq(_barracks.get_child_count(), 1, "only the plot")


func test_is_picked_over_the_plot_and_up_to_the_top_of_the_building() -> void:
	var plot := _barracks.box()
	_barracks.show_state(PadState.new(Type.BARRACKS, 1))
	var built := _barracks.box()
	assert_true(built.size.y > plot.size.y)
	assert_true(built.has_point(_barracks.position + Vector3(0.0, 0.5, 0.0)))
	assert_false(built.has_point(_barracks.position + Vector3(0.0, 3.0, 0.0)))

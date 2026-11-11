extends TestCase
## The parade ground: squads by unit, the barracks, the taps they tell.

const Type := UnitType.Value
const BType := BuildingType.Value

var _parade: ParadeScene
var _squads: Array[UnitType.Value] = []
var _barracks_taps := 0


func before_each() -> void:
	_parade = ParadeScene.new()
	_parade.squad_tapped.connect(_squads.append)
	_parade.barracks_tapped.connect(func() -> void: _barracks_taps += 1)
	(Engine.get_main_loop() as SceneTree).root.add_child(_parade)


func after_each() -> void:
	_parade.free()


## A squad of every unit, [param count] strong, the first [param locked] of
## them locked.
func _army(count: int, locked := 0) -> Array[SquadState]:
	var states: Array[SquadState] = []
	for type: UnitType.Value in Type.values():
		states.append(SquadState.new(type, count, type >= Type.values().size() - locked, false, str(type)))
	return states


func _tap(point: Vector3) -> void:
	_parade.camera.tapped.emit(_parade.camera.unproject_position(point))


func test_has_a_squad_for_each_unit_and_the_barracks_at_the_back() -> void:
	assert_eq(_parade.squads.size(), 6)
	assert_not_null(_parade.ground)
	assert_eq(_parade.barracks.position, ParadeLayout.at(ParadeLayout.BARRACKS))
	for type: UnitType.Value in Type.values():
		assert_eq(_parade.squads[type].position, ParadeLayout.pad_of(type))


func test_shows_nothing_of_the_squads_it_is_not_given() -> void:
	_parade.show_army([SquadState.new(Type.SCOUT, 4)], PadState.new(BType.BARRACKS, 1))
	assert_true(_parade.squads[Type.SCOUT].visible)
	assert_false(_parade.squads[Type.GUARDIAN].visible)


func test_stands_the_squads_by_their_counts() -> void:
	_parade.show_army(_army(7), PadState.new(BType.BARRACKS, 1))
	for type: UnitType.Value in Type.values():
		assert_eq(_parade.squads[type].figures.get_child_count(), 3, str(type))
	_parade.show_army(_army(61), PadState.new(BType.BARRACKS, 1))
	assert_eq(_parade.squads[Type.SCOUT].figures.get_child_count(), 6)


func test_every_unit_stands_as_a_different_solid_in_a_different_colour() -> void:
	_parade.show_army(_army(1), PadState.new(BType.BARRACKS, 1))
	var seen: Dictionary[String, bool] = {}
	for type: UnitType.Value in Type.values():
		var figure := _parade.squads[type].figures.get_child(0) as UnitStandIn
		var material := figure.body.material_override as StandardMaterial3D
		seen["%s %s" % [figure.shape.kind, material.albedo_color]] = true
		seen[str(figure.shape.kind)] = true
	assert_eq(seen.size(), 12, "six kinds, six colours")


func test_the_same_army_again_changes_nothing() -> void:
	_parade.show_army(_army(7), PadState.new(BType.BARRACKS, 1))
	var figure := _parade.squads[Type.SCOUT].figures.get_child(0)
	_parade.show_army(_army(7), PadState.new(BType.BARRACKS, 1))
	assert_eq(_parade.squads[Type.SCOUT].figures.get_child(0), figure)
	_parade.show_army(_army(8), PadState.new(BType.BARRACKS, 1))
	assert_eq(_parade.squads[Type.SCOUT].figures.get_child_count(), 3)


func test_shows_the_barracks_plot_or_the_building() -> void:
	_parade.show_army(_army(1), PadState.new(BType.BARRACKS, 0, false, true))
	assert_null(_parade.barracks.building)
	_parade.show_army(_army(1), PadState.new(BType.BARRACKS, 3))
	assert_eq((_parade.barracks.building as StandIn).level, 3)


func test_tells_the_squad_tapped_whatever_the_state_it_is_in() -> void:
	_parade.show_army(_army(5, 2), PadState.new(BType.BARRACKS, 1))
	for type: UnitType.Value in Type.values():
		_tap(ParadeLayout.pad_of(type) + Vector3.UP * 0.6)
	assert_eq(_squads, [Type.SCOUT, Type.HARPOONIST, Type.GUARDIAN, Type.DOME_BREAKER,
		Type.ABYSS_ADMIRAL, Type.SABOTEUR] as Array[UnitType.Value])
	assert_eq(_barracks_taps, 0)


func test_tells_the_barracks_tapped_built_or_not() -> void:
	var at := ParadeLayout.at(ParadeLayout.BARRACKS) + Vector3.UP * 0.4
	_parade.show_army(_army(5), PadState.new(BType.BARRACKS, 0))
	_tap(at)
	_parade.show_army(_army(5), PadState.new(BType.BARRACKS, 4))
	_tap(at)
	assert_eq(_barracks_taps, 2)
	assert_eq(_squads.size(), 0)


func test_a_tap_beside_everything_tells_nothing() -> void:
	_parade.show_army(_army(5), PadState.new(BType.BARRACKS, 1))
	_tap(Vector3(0.0, 0.0, 9.0))
	_tap(Vector3(-9.0, 0.0, 0.0))
	assert_eq(_squads.size() + _barracks_taps, 0)


func test_a_squad_not_shown_cannot_be_tapped() -> void:
	_parade.show_army([SquadState.new(Type.SCOUT, 4)], PadState.new(BType.BARRACKS, 1))
	_tap(ParadeLayout.pad_of(Type.GUARDIAN) + Vector3.UP * 0.6)
	assert_eq(_squads.size(), 0)
	assert_false(_parade.boxes().has(Type.GUARDIAN))


func test_frames_the_deck_between_the_bars_and_over_the_place_bar() -> void:
	_parade.frame(0.1, 0.2)
	var size := _parade.get_viewport().get_visible_rect().size
	var fitted := OrbitFrame.fit(ParadeLayout.OUTLINE, OrbitRig.DEFAULT_YAW, OrbitRig.DEFAULT_PITCH,
		size.x / size.y, OrbitCamera.FOV, 0.1, 0.2 + ParadeScene.PLACE_BAR_ROOM)
	assert_almost_eq(_parade.camera.rig.default_distance, fitted.x, 1e-4)


func test_turns_the_shadows_on_and_off() -> void:
	_parade.set_shadows(false)
	assert_false(_parade.key_light.shadow_enabled)
	_parade.set_shadows(true)
	assert_true(_parade.key_light.shadow_enabled)

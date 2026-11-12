extends TestCase
## The base in 3D: the island, its rampart up to its tier, the prototype's
## buildings on their pads, the others marked empty, lit from the surface
## and seen by the orbit camera, which picks the pad under a tap.

var _base: BaseScene
var _taps: Array[BuildingType.Value] = []


func before_each() -> void:
	_base = BaseScene.new()
	_base.building_tapped.connect(_taps.append)
	(Engine.get_main_loop() as SceneTree).root.add_child(_base)


func after_each() -> void:
	_base.free()


func test_stands_the_prototype_buildings_on_the_island() -> void:
	assert_not_null(_base.get_node("Island/Island"))
	assert_eq(_base.buildings.names(), BaseScene.BUILT)
	assert_false(_base.pads.is_empty(&"Headquarters"))
	assert_true(_base.pads.is_empty(&"Barracks"))


func test_shows_the_rampart_up_to_its_tier() -> void:
	assert_eq(_base.rampart_tier, 1)
	assert_eq(_tiers(), [true, false, false])
	_base.rampart_tier = 3
	assert_eq(_tiers(), [true, true, true])
	_base.rampart_tier = 9
	assert_eq(_base.rampart_tier, 3)
	_base.rampart_tier = 2
	assert_eq(_tiers(), [true, true, false])


func test_is_lit_and_seen_from_the_game_view() -> void:
	assert_true(_base.key_light.shadow_enabled)
	assert_true(_base.camera.current)
	assert_eq(_base.camera.rig.yaw, OrbitRig.DEFAULT_YAW)


func test_fills_the_water_with_light_and_specks() -> void:
	assert_true(_base.water.environment.fog_enabled)
	assert_eq(_base.find_children("*", "LightShafts", false, false).size(), 1)
	assert_true(_base.snow.emitting)
	assert_true(_base.bubbles.emitting)
	assert_eq(_base.bubbles.emission_points.size(), BaseScene.BUILT.size() * 6)


func test_animates_the_buildings() -> void:
	var dish := _base.buildings.building(&"Headquarters").get_node("Headquarters/Dish") as Node3D
	_base.motion.advance(1.0)
	assert_ne(dish.rotation.y, 0.0)


func test_turns_its_costly_effects_on_and_off() -> void:
	_base.set_shadows(false)
	_base.set_glow(false)
	_base.set_particles(false)
	assert_false(_base.key_light.shadow_enabled)
	assert_false(_base.water.environment.glow_enabled)
	assert_false(_base.snow.emitting or _base.bubbles.emitting or _base.life.visible)
	_base.set_shadows(true)
	_base.set_glow(true)
	_base.set_particles(true)
	assert_true(_base.key_light.shadow_enabled)
	assert_true(_base.water.environment.glow_enabled)
	assert_true(_base.snow.emitting and _base.bubbles.emitting and _base.life.visible)


func test_casts_the_shadows_worth_their_cost_only() -> void:
	for mesh: String in ["Island_glow", "Island_algae", "Island_stone", "Island_rock", "Island_coral"]:
		var quiet := _base.get_node("Island/Island/" + mesh) as GeometryInstance3D
		assert_eq(quiet.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, mesh)
	var metal := _base.get_node("Island/Island/Island_metal") as GeometryInstance3D
	assert_eq(metal.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_ON)
	var keep := _base.buildings.building(&"Headquarters").get_node("Headquarters/Headquarters_hull")
	assert_eq((keep as GeometryInstance3D).cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_ON)
	var wall := _base.get_node("Rampart/Tier1/Tier1_reef") as GeometryInstance3D
	assert_eq(wall.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_ON)


func test_fits_the_island_to_the_screen() -> void:
	_base.frame(0.12)
	var size := _base.get_viewport().get_visible_rect().size
	var fitted := OrbitFrame.fit(BaseScene.OUTLINE, OrbitRig.DEFAULT_YAW, OrbitRig.DEFAULT_PITCH,
		size.x / size.y, OrbitCamera.FOV, 0.12)
	assert_almost_eq(_base.camera.rig.default_distance, fitted.x, 1e-4)
	assert_almost_eq(_base.camera.rig.lift, fitted.y, 1e-4)


func test_tells_the_building_under_a_tap() -> void:
	var headquarters := _base.pads.origin_of(&"Headquarters") + Vector3.UP
	_base.camera.tapped.emit(_base.camera.unproject_position(headquarters))
	assert_eq(_taps, [BuildingType.Value.HEADQUARTERS] as Array[BuildingType.Value])
	_base.camera.tapped.emit(Vector2(-1000.0, -1000.0))
	assert_eq(_taps.size(), 1, "a tap on the sea picks nothing")


func _tiers() -> Array[bool]:
	var shown: Array[bool] = []
	for tier: Node in _base.get_node("Rampart").get_children():
		shown.append((tier as Node3D).visible)
	return shown

extends TestCase
## The glow behind the buildings that can rise.

const ISLAND := preload("res://assets/models/base_island.glb")
const Type := BuildingType.Value

var _island: Node3D
var _pads: BasePads
var _buildings: BaseBuildings
var _halos: PadHalos


func before_each() -> void:
	_island = ISLAND.instantiate() as Node3D
	_pads = BasePads.new(_island.get_node("Pads") as Node3D)
	_buildings = BaseBuildings.new()
	_halos = PadHalos.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_halos)


func after_each() -> void:
	for node: Node in [_island, _buildings, _halos]:
		node.free()


func test_glows_behind_a_building_that_can_rise() -> void:
	_show([PadState.new(Type.HEADQUARTERS, 2, false, true)])
	assert_eq(_halos.get_child_count(), 1)
	var halo := _halos.get_child(0) as MeshInstance3D
	var origin := _pads.origin_of(&"Headquarters")
	var top := ModelBounds.top_of(_buildings.building(&"Headquarters"))
	assert_eq([halo.position.x, halo.position.z], [origin.x, origin.z])
	assert_true(halo.position.y > origin.y and halo.position.y < top, "in the building's height")
	assert_true(halo.scale.x > top - origin.y, "wider than the building is tall")


func test_a_wide_low_building_glows_by_its_pad() -> void:
	_show([PadState.new(Type.BARRACKS, 1, false, true)])
	var halo := _halos.get_child(0) as MeshInstance3D
	assert_true(halo.scale.x >= PadHalos.REACH * 2.0 * _pads.radius_of(&"Barracks"))


func test_glows_for_none_of_the_others() -> void:
	_show([
		PadState.new(Type.HEADQUARTERS, 2),
		PadState.new(Type.BARRACKS, 1, true, true),
		PadState.new(Type.LABORATORY, 0, false, true),
		PadState.new(Type.CORAL_MINE, 0, false, false, true),
	])
	assert_eq(_halos.get_child_count(), 0)
	assert_false(_halos.is_pulsing())


func test_draws_anew_with_each_change() -> void:
	_show([PadState.new(Type.BARRACKS, 1, false, true), PadState.new(Type.LABORATORY, 2, false, true)])
	_show([PadState.new(Type.LABORATORY, 2, false, true)])
	assert_eq(_halos.get_child_count(), 1)


func test_every_halo_shares_one_soft_additive_billboard() -> void:
	_show([PadState.new(Type.BARRACKS, 1, false, true), PadState.new(Type.LABORATORY, 2, false, true)])
	var first := _halos.get_child(0) as MeshInstance3D
	assert_eq(first.mesh, (_halos.get_child(1) as MeshInstance3D).mesh)
	var material := _material(first)
	assert_eq(material.blend_mode, BaseMaterial3D.BLEND_MODE_ADD)
	assert_eq(material.billboard_mode, BaseMaterial3D.BILLBOARD_ENABLED)
	assert_eq(material.shading_mode, BaseMaterial3D.SHADING_MODE_UNSHADED)
	assert_eq(first.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	assert_eq(Color(material.albedo_color, 1.0), WorldPalette.UPGRADE)


func test_breathes_while_there_is_a_halo() -> void:
	_show([PadState.new(Type.BARRACKS, 1, false, true)])
	assert_true(_halos.is_pulsing())
	_show([])
	assert_false(_halos.is_pulsing())


func test_a_breath_dims_and_swells_the_halos() -> void:
	_show([PadState.new(Type.BARRACKS, 1, false, true)])
	var halo := _halos.get_child(0) as MeshInstance3D
	var material := _material(halo)
	_halos._show(0.0)
	var dim := material.albedo_color.a
	var small := halo.scale.x
	_halos._show(1.0)
	assert_almost_eq(dim, PadHalos.ALPHA.x, 1e-4)
	assert_almost_eq(material.albedo_color.a, PadHalos.ALPHA.y, 1e-4)
	assert_true(halo.scale.x > small)


func test_holds_still_with_reduced_motion() -> void:
	_halos.reduced_motion = true
	_show([PadState.new(Type.BARRACKS, 1, false, true)])
	assert_false(_halos.is_pulsing())
	assert_eq(_halos.pulse, 1.0)


func test_stops_when_it_leaves_the_tree() -> void:
	_show([PadState.new(Type.BARRACKS, 1, false, true)])
	var root := (Engine.get_main_loop() as SceneTree).root
	root.remove_child(_halos)
	assert_false(_halos.is_pulsing())
	root.add_child(_halos)
	assert_true(_halos.is_pulsing())


func _show(states: Array[PadState]) -> void:
	_buildings.build(states, _pads)
	_halos.show_halos(states, _pads, _buildings)


func _material(halo: MeshInstance3D) -> StandardMaterial3D:
	return (halo.mesh as QuadMesh).material as StandardMaterial3D

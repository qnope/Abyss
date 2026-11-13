extends MapTestCase
## The shadows of the map: its floor and scenery cast none, and what stands on
## the cells casts them, on a floor and a scenery that take them, only while the
## view is close, when they can be seen.

const NEAR := MapCamera.CLOSE - 0.05

var _scene: MapScene


func before_each() -> void:
	_scene = MapScene.new()
	mounted(_scene)
	_scene.frame(0.1, 0.1)
	var state := level_of(6, 6, [], true)
	put(state, 1, 1, Content.RESOURCE_BONUS)
	put(state, 3, 3, Content.RUINS)
	_scene.show_level(state)


func _modes(node: Node) -> Array[GeometryInstance3D.ShadowCastingSetting]:
	var modes: Array[GeometryInstance3D.ShadowCastingSetting] = []
	var meshes := node.find_children("*", "GeometryInstance3D", true, false)
	if node is GeometryInstance3D:
		meshes.append(node)
	for mesh: Node in meshes:
		modes.append((mesh as GeometryInstance3D).cast_shadow)
	return modes


func _all_off(node: Node) -> bool:
	var modes := _modes(node)
	return not modes.is_empty() and modes.all(func(mode: int) -> bool:
		return mode == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)


func _zoom(share: float) -> void:
	_scene.camera.pan.distance = _scene.camera.pan.default_distance * share
	_scene.camera._process(0.0)


## Whether each surface of each layer of [param part] takes the shadows.
func _taking(part: Node) -> Array[bool]:
	var found: Array[bool] = []
	for layer: MultiMeshInstance3D in part.get_children():
		var mesh := layer.multimesh.mesh
		for surface in mesh.get_surface_count():
			found.append(not (mesh.surface_get_material(surface) as BaseMaterial3D).disable_receive_shadows)
	return found


## Whether the floor and the scenery all take the shadows ([param on]), or none does.
func _ground_takes(on: bool) -> bool:
	var found := _taking(_scene.tiles) + _taking(_scene.surroundings.backdrop)
	return found.size() > 6 and found.count(on) == found.size()


## Where every tile of the floor and every piece of the scenery lies.
func _places() -> Array[Transform3D]:
	var found: Array[Transform3D] = []
	for layer: MultiMeshInstance3D in _scene.tiles.get_children() + _scene.surroundings.backdrop.get_children():
		for index in layer.multimesh.instance_count:
			found.append(layer.multimesh.get_instance_transform(index))
	return found


func test_the_floor_and_the_scenery_cast_no_shadow() -> void:
	assert_true(_all_off(_scene.tiles))
	assert_true(_all_off(_scene.fog) or _scene.fog.get_child_count() == 0)
	assert_true(_all_off(_scene.surroundings.backdrop))


func test_the_contents_cast_none_from_the_default_view() -> void:
	assert_eq(_scene.contents.by_cell.size(), 2)
	for content: Node3D in _scene.contents.by_cell.values():
		assert_true(_all_off(content))


func test_the_contents_cast_theirs_when_the_view_comes_close() -> void:
	_zoom(NEAR)
	for content: Node3D in _scene.contents.by_cell.values():
		var modes := _modes(content)
		assert_false(modes.is_empty())
		assert_true(modes.all(func(mode: int) -> bool: return mode == GeometryInstance3D.SHADOW_CASTING_SETTING_ON))
	_zoom(1.0)
	for content: Node3D in _scene.contents.by_cell.values():
		assert_true(_all_off(content), "and stop when it leaves")


func test_a_content_that_is_a_mesh_itself_is_set_too() -> void:
	var mesh := MeshInstance3D.new()
	_scene.contents.add_child(mesh)
	_scene.contents.cast_shadows(true)
	assert_eq(mesh.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_ON)
	_scene.contents.cast_shadows(false)
	assert_eq(mesh.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)


func test_the_contents_drawn_while_close_cast_at_once() -> void:
	_zoom(0.5)
	var state := level_of(6, 6, [], true)
	put(state, 2, 2, Content.RESOURCE_BONUS)
	_scene.show_level(state)
	var content: Node3D = _scene.contents.by_cell[Vector2i(2, 2)]
	assert_false(_all_off(content))


func test_the_floor_and_the_scenery_take_no_shadow_from_the_default_view() -> void:
	assert_true(_ground_takes(false))


func test_they_take_the_shadows_when_the_view_comes_close() -> void:
	_zoom(NEAR)
	assert_true(_ground_takes(true))
	_zoom(1.0)
	assert_true(_ground_takes(false), "and stop when it leaves")


func test_a_level_drawn_while_close_takes_them_at_once() -> void:
	_zoom(NEAR)
	_scene.show_level(level_of(5, 5, [], true))
	assert_true(_ground_takes(true))
	_zoom(1.0)
	_scene.show_level(level_of(4, 4, [], true))
	assert_true(_ground_takes(false), "and one drawn once the view has left takes none")


func test_the_switch_swaps_the_mesh_and_leaves_the_tiles_where_they_lie() -> void:
	var parts := MapScenery.parts(MapScenery.TERRAINS[0])
	var before := _places()
	assert_true(before.size() > 36)
	for layer: MultiMeshInstance3D in _scene.tiles.get_children():
		assert_eq(layer.multimesh.mesh, ShadowlessMesh.of(parts[layer.name]))
	_zoom(NEAR)
	assert_eq(_places(), before)
	for layer: MultiMeshInstance3D in _scene.tiles.get_children():
		assert_eq(layer.multimesh.mesh, parts[layer.name], "the model's own, as it is")
	_zoom(1.0)
	assert_eq(_places(), before)


func test_the_fog_is_left_as_it_is() -> void:
	_scene.show_level(level_of(6, 6, [Vector2i(0, 0)]))
	var clouds := MapScenery.parts(MapScenery.FOG)
	assert_true(_scene.fog.get_child_count() > 0)
	for share: float in [1.0, NEAR, 1.0]:
		_zoom(share)
		for layer: MultiMeshInstance3D in _scene.fog.get_children():
			assert_eq(layer.multimesh.mesh, clouds[layer.name])

extends MapTestCase
## The shadows of the map: its floor and scenery cast none, and what stands on
## the cells casts them only while the view is close, when they can be seen.

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


func test_the_floor_and_the_scenery_cast_no_shadow() -> void:
	assert_true(_all_off(_scene.tiles))
	assert_true(_all_off(_scene.fog) or _scene.fog.get_child_count() == 0)
	assert_true(_all_off(_scene.surroundings.backdrop))


func test_the_contents_cast_none_from_the_default_view() -> void:
	assert_eq(_scene.contents.by_cell.size(), 2)
	for content: Node3D in _scene.contents.by_cell.values():
		assert_true(_all_off(content))


func test_the_contents_cast_theirs_when_the_view_comes_close() -> void:
	_zoom(MapCamera.CLOSE - 0.05)
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

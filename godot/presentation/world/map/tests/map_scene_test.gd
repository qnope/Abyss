extends MapTestCase
## The map in 3D: the tiles of a level dark where not seen, what stands on the
## cells seen, the scouts, the taps it tells and the levels it switches
## between.

var _scene: MapScene
var _taps: Array[Vector3i] = []


func before_each() -> void:
	_scene = MapScene.new()
	_scene.cell_tapped.connect(func(level: int, x: int, y: int) -> void: _taps.append(Vector3i(level, x, y)))
	mounted(_scene)


func _tap(x: int, y: int, width := 6, height := 6) -> void:
	var point := _scene.to_global(MapGrid.at(x, y, width, height) + Vector3.UP * MapPick.HEIGHT)
	_scene.camera.tapped.emit(_scene.camera.unproject_position(point))


## Every node the level is drawn with: the creature, the tiles, the clouds, the
## scenery, the contents and the scouts.
func _nodes() -> Array[Node]:
	var found: Array[Node] = [_scene.surroundings.ambient.creature]
	for part: Node in [_scene.tiles, _scene.fog, _scene.surroundings.backdrop, _scene.contents, _scene.scouts]:
		found.append_array(part.get_children())
	return found


func test_shows_the_fog_where_the_game_has_not_seen_and_the_floor_where_it_has() -> void:
	var game := GameFactory.new_single_player("Nemo", 1)
	var human := game.human_player()
	var state := MapLevelState.new(1, game.levels[1], human.id, human.revealed_cells_set_on_level(1))
	_scene.show_level(state)
	var seen := human.revealed_cells_on_level(1).size()
	var fog := 0
	for part_name in _scene.tiles.counts:
		if String(part_name).begins_with("Fog"):
			fog += _scene.tiles.counts[part_name]
	assert_eq(fog + seen, game.levels[1].cells.size())
	assert_true(seen > 0 and fog > seen)
	assert_eq(_scene.level, 1)


func test_stands_what_the_cells_seen_hold() -> void:
	var state := level_of(6, 6, [Vector2i(1, 1)])
	put(state, 1, 1, Content.RUINS)
	put(state, 4, 4, Content.RUINS)
	_scene.show_level(state)
	assert_eq(_scene.contents.by_cell.keys(), [Vector2i(1, 1)])
	var ruins := _scene.contents.by_cell[Vector2i(1, 1)]
	state.revealed[Vector2i(4, 4)] = true
	_scene.show_level(state)
	assert_eq(_scene.contents.by_cell.size(), 2)
	assert_eq(_scene.contents.by_cell[Vector2i(1, 1)], ruins, "the one already standing keeps its node")


func test_the_same_state_again_keeps_every_node_of_the_level() -> void:
	var state := level_of(6, 6, [Vector2i(1, 1), Vector2i(2, 1)])
	put(state, 1, 1, Content.RUINS)
	put(state, 4, 4, Content.WRECK)
	state.pending[Vector2i(3, 3)] = Vector2i(1, 1)
	_scene.show_level(state)
	var before := _nodes()
	var counts := [_scene.tiles.counts.duplicate(), _scene.fog.counts.duplicate()]
	_scene.show_level(state)
	assert_eq(_nodes(), before, "the very nodes drawn first")
	assert_true(before.size() >= 14, "tiles, clouds, scenery, a creature, two contents and a scout")
	assert_eq([_scene.tiles.counts, _scene.fog.counts], counts)


func test_shows_the_scouts_on_their_way() -> void:
	var state := level_of(6, 6)
	state.pending[Vector2i(2, 2)] = Vector2i(0, 0)
	_scene.show_level(state)
	assert_eq(_scene.scouts.tokens.keys(), [Vector2i(2, 2)])


func test_tells_the_cell_tapped_with_its_level() -> void:
	_scene.show_level(level_of(6, 6, [], true, 2))
	_scene.frame(0.1, 0.1)
	for cell: Vector2i in [Vector2i(0, 0), Vector2i(3, 2), Vector2i(5, 5)]:
		_tap(cell.x, cell.y)
	assert_eq(_taps, [Vector3i(2, 0, 0), Vector3i(2, 3, 2), Vector3i(2, 5, 5)] as Array[Vector3i])


func test_a_tap_beside_the_map_or_before_a_level_is_shown_tells_nothing() -> void:
	_scene.camera.tapped.emit(Vector2(10.0, 10.0))
	_scene.show_level(level_of(6, 6))
	_scene.frame(0.1, 0.1)
	_scene.camera.tapped.emit(Vector2(1.0, 1.0))
	assert_eq(_taps.size(), 0)


func test_a_new_level_is_framed_anew_with_the_view_on_its_middle() -> void:
	_scene.show_level(level_of(6, 6))
	_scene.frame(0.1, 0.1)
	_scene.camera.pan.drag(Vector2(200.0, 100.0), 0.016)
	_scene.show_level(level_of(6, 6))
	assert_ne(_scene.camera.pan.goal_target, Vector3.ZERO, "the same level again keeps the view")
	_scene.show_level(level_of(8, 8, [], false, 2))
	assert_eq(_scene.camera.pan.target, Vector3.ZERO)
	assert_true(_scene.camera.pan.is_settled())
	assert_eq(_scene.camera.pan.bounds.size, Vector2(8.0, 8.0))
	assert_eq(_scene.level, 2)


func test_is_framed_between_the_bars_and_the_level_selector() -> void:
	_scene.show_level(level_of(26, 26))
	_scene.frame(0.1, 0.2)
	var size := _scene.get_viewport().get_visible_rect().size
	var fitted := OrbitFrame.fit(MapGrid.outline(26, 26), MapRig.YAW, MapRig.PITCH,
		size.x / size.y, OrbitCamera.FOV, 0.1 + MapScene.LEVEL_BAR_ROOM, 0.2)
	assert_almost_eq(_scene.camera.rig.default_distance, fitted.x, 1e-4)


func test_frames_nothing_until_a_level_is_shown() -> void:
	_scene.frame(0.1, 0.2)
	assert_eq(_scene.camera.rig.default_distance, OrbitRig.DEFAULT_DISTANCE)


func test_turns_the_shadows_on_and_off() -> void:
	_scene.set_shadows(false)
	assert_false(_scene.key_light.shadow_enabled)
	_scene.set_shadows(true)
	assert_true(_scene.key_light.shadow_enabled)

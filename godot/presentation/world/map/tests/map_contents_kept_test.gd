extends MapTestCase
## What stands on the cells is kept from a draw of the map to the next: a
## content whose look is the same keeps its node, and only one that appeared,
## changed or left is stood, replaced or freed.

var _contents: MapContents


func before_each() -> void:
	_contents = mounted(MapContents.new()) as MapContents


## A cell seen that holds [param kind].
func _holding(x: int, y: int, kind: Kind) -> MapLook:
	var look := MapLook.new(x, y, TerrainType.Value.PLAIN, true)
	look.content = kind
	return look


## A treasure, a Faille, ruins and the player's base, in the order of the grid.
func _four() -> Array[MapLook]:
	return [_holding(1, 1, Kind.TREASURE), _holding(4, 1, Kind.FAILLE),
		_holding(3, 3, Kind.RUINS), _holding(5, 5, Kind.HOME)]


## The shadow settings the meshes of [param content] wear, each told once.
func _shadows(content: Node) -> Array:
	var found: Dictionary[int, bool] = {}
	for mesh: Node in content.find_children("*", "GeometryInstance3D", true, false):
		found[(mesh as GeometryInstance3D).cast_shadow] = true
	return found.keys()


func test_the_same_looks_again_keep_every_content() -> void:
	_contents.show_looks(_four(), 6, 6)
	var nodes := _contents.get_children()
	var by_cell := _contents.by_cell.duplicate()
	_contents.show_looks(_four(), 6, 6)
	assert_eq(_contents.get_children(), nodes, "the very nodes stood first")
	assert_eq(_contents.by_cell, by_cell)


func test_a_content_that_appears_is_added_in_its_place_and_the_others_are_kept() -> void:
	var looks := _four()
	_contents.show_looks([looks[0], looks[2]] as Array[MapLook], 6, 6)
	var treasure := _contents.by_cell[Vector2i(1, 1)]
	var ruins := _contents.by_cell[Vector2i(3, 3)]
	_contents.show_looks(looks, 6, 6)
	assert_eq(_contents.by_cell.keys(), [Vector2i(1, 1), Vector2i(4, 1), Vector2i(3, 3), Vector2i(5, 5)])
	assert_eq(_contents.get_children(), _contents.by_cell.values(), "in the order of the looks, as drawn afresh")
	assert_eq(_contents.by_cell[Vector2i(1, 1)], treasure)
	assert_eq(_contents.by_cell[Vector2i(3, 3)], ruins)
	var added := _contents.by_cell[Vector2i(4, 1)]
	assert_eq(added.name, &"Cell4_1")
	assert_eq(added.position, MapGrid.at(4, 1, 6, 6))


func test_a_content_emptied_tinted_or_changed_is_replaced_and_one_gone_is_freed() -> void:
	_contents.show_looks(_four() + ([_holding(0, 5, Kind.LAIR_EASY)] as Array[MapLook]), 6, 6)
	var treasure := _contents.by_cell[Vector2i(1, 1)]
	var faille := _contents.by_cell[Vector2i(4, 1)]
	var ruins := _contents.by_cell[Vector2i(3, 3)]
	var home := _contents.by_cell[Vector2i(5, 5)]
	var lair := _contents.by_cell[Vector2i(0, 5)]
	var next := _four() + ([_holding(0, 5, Kind.LAIR_HARD)] as Array[MapLook])
	next[0].dimmed = true
	next[1].tint = Color.CYAN
	next.remove_at(2)
	_contents.show_looks(next, 6, 6)
	var stands := func(node: Variant) -> bool: return is_instance_valid(node)
	assert_eq([treasure, faille, ruins, lair].map(stands), [false, false, false, false])
	assert_true(MapProbe.is_dimmed(_contents.by_cell[Vector2i(1, 1)]))
	assert_eq(MapProbe.tint_of(_contents.by_cell[Vector2i(4, 1)]), Color.CYAN)
	assert_false(_contents.by_cell.has(Vector2i(3, 3)))
	assert_eq(_contents.by_cell[Vector2i(5, 5)], home, "the one that did not change is kept")
	assert_eq(_contents.get_children(), _contents.by_cell.values())
	assert_eq(_contents.get_child_count(), 4)


func test_a_content_stands_anew_when_its_floor_its_span_or_the_map_changes() -> void:
	var wreck := MapLook.new(1, 1, TerrainType.Value.PLAIN, false)
	wreck.content = Kind.WRECK
	_contents.show_looks([wreck] as Array[MapLook], 4, 4)
	var places: Array[Vector3] = []
	for change: Vector3i in [Vector3i(4, 4, 1), Vector3i(6, 4, 1), Vector3i(6, 4, 2)]:
		var before := _contents.by_cell[Vector2i(1, 1)]
		var seen := _holding(1, 1, Kind.WRECK)
		seen.span = change.z
		_contents.show_looks([seen] as Array[MapLook], change.x, change.y)
		assert_false(is_instance_valid(before))
		places.append(_contents.by_cell[Vector2i(1, 1)].position)
	assert_eq(places, [MapGrid.at(1, 1, 4, 4), MapGrid.at(1, 1, 6, 4), MapGrid.at(1, 1, 6, 4) + Vector3(0.5, 0.0, 0.5)])


func test_a_content_kept_that_was_left_hidden_shows_again() -> void:
	_contents.show_looks(_four(), 6, 6)
	var treasure := _contents.by_cell[Vector2i(1, 1)]
	treasure.visible = false
	_contents.show_looks(_four(), 6, 6)
	assert_eq(_contents.by_cell[Vector2i(1, 1)], treasure)
	assert_true(treasure.visible)


func test_a_content_kept_casts_its_shadow_while_the_view_is_close() -> void:
	_contents.cast_shadows(true)
	_contents.show_looks(_four(), 6, 6)
	var nodes := _contents.get_children()
	_contents.show_looks(_four(), 6, 6)
	assert_eq(_contents.get_children(), nodes)
	for content in nodes:
		assert_eq(_shadows(content), [GeometryInstance3D.SHADOW_CASTING_SETTING_ON], content.name)
	_contents.cast_shadows(false)
	_contents.show_looks(_four(), 6, 6)
	for content in nodes:
		assert_eq(_shadows(content), [GeometryInstance3D.SHADOW_CASTING_SETTING_OFF], content.name)


func test_a_content_with_a_material_of_its_own_is_replaced_before_a_frame_is_drawn() -> void:
	var held := _holding(4, 1, Kind.FAILLE)
	held.tint = Color.GOLD
	_contents.show_looks([held] as Array[MapLook], 6, 6)
	var taken := _holding(4, 1, Kind.FAILLE)
	taken.tint = Color.CYAN
	_contents.show_looks([taken] as Array[MapLook], 6, 6)
	assert_eq(MapProbe.tint_of(_contents.by_cell[Vector2i(4, 1)]), Color.CYAN)
	_contents.show_looks([] as Array[MapLook], 6, 6)
	assert_true(_contents.by_cell.is_empty(), "and the renderer complained of neither")

extends RivalGameCase
## test/presentation/screens/game/game_screen_map_actions_cells_test.dart:
## where a touch on a cell leads.

const Kind := CellRoute.Kind
const AT := Vector2i(2, 2)


func _route(x := AT.x, y := AT.y, level := 1) -> CellRoute:
	return CellRoute.of(game, level, x, y)


func _with(content: Content, changes := {}) -> void:
	start({AT: cell_of(content, changes)})


func test_a_hidden_cell_is_explored_where_it_was_touched() -> void:
	start({}, [AT])
	var route := _route()
	assert_eq(route.kind, Kind.EXPLORE)
	assert_eq([route.x, route.y], [2, 2])


func test_a_cell_already_emptied_by_the_human_is_visited() -> void:
	_with(Content.RUINS, {"collected_by": "me"})
	assert_eq(_route().kind, Kind.VISITED)


func test_a_cell_emptied_by_a_faction_is_taken_and_tells_which() -> void:
	start_with_rival({AT: cell_of(Content.RUINS, {"collected_by": Faction.new(RIVAL).id()})})
	var route := _route()
	assert_eq(route.kind, Kind.TAKEN)
	assert_eq(route.rival.personality, RIVAL)


func test_a_cell_emptied_by_someone_unknown_is_visited() -> void:
	_with(Content.RUINS, {"collected_by": "someone"})
	assert_eq(_route().kind, Kind.VISITED)


func test_the_base_is_home() -> void:
	start()
	assert_eq(_route(5, 5).kind, Kind.HOME)


func test_a_rival_base_is_told_on_the_first_level() -> void:
	start_with_rival()
	assert_eq(_route(RIVAL_BASE.x, RIVAL_BASE.y).kind, Kind.FACTION_BASE)
	assert_eq(_route(7, 8).kind, Kind.PLAIN)


func test_a_bare_cell_is_plain() -> void:
	start()
	assert_eq(_route(1, 4).kind, Kind.PLAIN)


func test_treasures_ruins_and_wrecks_are_searched() -> void:
	for content: Content in [Content.RESOURCE_BONUS, Content.RUINS, Content.WRECK]:
		_with(content)
		assert_eq(_route().kind, Kind.TREASURE, str(content))


func test_a_lair_needs_its_monsters_to_be_one() -> void:
	_with(Content.MONSTER_LAIR)
	assert_eq(_route().kind, Kind.PLAIN)
	_with(Content.MONSTER_LAIR, {"lair": MonsterLair.new(MonsterDifficulty.Value.EASY, 3)})
	assert_eq(_route().kind, Kind.LAIR)


func test_a_post_needs_its_base_to_be_one() -> void:
	_with(Content.TRANSITION_BASE)
	assert_eq(_route().kind, Kind.PLAIN)
	var post := TransitionBase.new(TransitionBaseType.Value.FAILLE, "faille:0")
	_with(Content.TRANSITION_BASE, {"transition_base": post})
	assert_eq(_route().kind, Kind.POST)


func test_a_passage_and_the_parts_of_the_volcano() -> void:
	_with(Content.PASSAGE)
	assert_eq(_route().kind, Kind.PASSAGE)
	_with(Content.VOLCANIC_KERNEL_PART)
	assert_eq(_route().kind, Kind.PLAIN)


func test_any_cell_of_the_volcano_acts_on_its_anchor() -> void:
	var overrides: Dictionary[Vector2i, MapCell] = {AT: cell_of(Content.VOLCANIC_KERNEL)}
	var parts: Array[Vector2i] = [Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3)]
	for at in parts:
		overrides[at] = cell_of(Content.VOLCANIC_KERNEL_PART)
	start(overrides, parts)
	var footprint: Array[Vector2i] = [AT]
	footprint.append_array(parts)
	for at in footprint:
		var route := _route(at.x, at.y)
		assert_eq(route.kind, Kind.KERNEL)
		assert_eq([route.x, route.y], [2, 2])


func test_a_captured_kernel_keeps_its_own_sheet() -> void:
	_with(Content.VOLCANIC_KERNEL, {"collected_by": "me"})
	assert_eq(_route().kind, Kind.KERNEL)

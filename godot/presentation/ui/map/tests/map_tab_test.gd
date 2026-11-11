extends MapSheetCase
## game_screen_tabs.dart and game_screen_map_actions.dart (`buildMapTab`): the
## level on show and the levels the game holds.

var _levels: Array[int] = []


func _tab() -> MapTab:
	var tab := MapTab.new(game)
	tab.level_changed.connect(_levels.append)
	mount(tab)
	return tab


func _with_levels(count: int) -> void:
	for level in range(2, count + 1):
		game.levels[level] = MapSamples.plain_map(SIZE, SIZE)


func test_starts_on_the_first_level() -> void:
	var tab := _tab()
	assert_eq(tab.level, 1)
	assert_eq(tab.selector.current, 1)


func test_opens_the_levels_the_game_holds() -> void:
	_with_levels(2)
	var tab := _tab()
	assert_eq(tab.selector.unlocked, [1, 2] as Array[int])
	assert_true(tab.selector.chips[3].disabled)


func test_choosing_a_level_shows_it_and_tells_it() -> void:
	_with_levels(3)
	var tab := _tab()
	press("Niv. 3 : Noyau")
	assert_eq(tab.level, 3)
	assert_eq(tab.selector.current, 3)
	assert_eq(_levels, [3] as Array[int])


func test_ignores_a_level_the_game_does_not_hold() -> void:
	var tab := _tab()
	tab.choose(2)
	assert_eq(tab.level, 1)
	assert_eq(_levels, [] as Array[int])


func test_goes_back_to_the_first_level_if_the_game_loses_the_one_shown() -> void:
	_with_levels(2)
	var tab := _tab()
	tab.choose(2)
	game.levels.erase(2)
	tab.refresh()
	assert_eq(tab.level, 1)


func test_refreshing_opens_a_level_the_game_gained() -> void:
	var tab := _tab()
	assert_true(tab.selector.chips[2].disabled)
	_with_levels(2)
	tab.refresh()
	assert_false(tab.selector.chips[2].disabled)


func test_lets_the_touches_through_to_the_map() -> void:
	var tab := _tab()
	assert_eq(tab.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(tab.selector.mouse_filter, Control.MOUSE_FILTER_IGNORE)

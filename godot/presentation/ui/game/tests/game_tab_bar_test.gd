extends UiTestCase
## The bottom navigation: Base, Carte, Armée, Tech, one lit
## (game_bottom_bar_test.dart).

var _chosen: Array[GameTab.Value] = []


func test_shows_the_four_tabs_with_their_names_and_the_first_lit() -> void:
	var bar := _bar()
	assert_eq(texts(bar), PackedStringArray(["Base", "Carte", "Armée", "Tech"]))
	assert_eq(bar.selected(), GameTab.Value.BASE)
	assert_true(bar.button(GameTab.Value.BASE).button_pressed)
	assert_false(bar.button(GameTab.Value.MAP).button_pressed)
	assert_no_raw_keys()


func test_each_tab_has_its_icon_over_its_name() -> void:
	var bar := _bar()
	for tab: GameTab.Value in GameTab.Value.values():
		var button := bar.button(tab)
		assert_eq(button.icon.resource_path, GameTab.icon_path(tab))
		assert_eq(button.icon_alignment, HORIZONTAL_ALIGNMENT_CENTER)
		assert_eq(button.vertical_icon_alignment, VERTICAL_ALIGNMENT_TOP)


func test_a_touch_chooses_the_tab_and_lights_it() -> void:
	var bar := _bar()
	press("Carte")
	assert_eq(_chosen, [GameTab.Value.MAP] as Array[GameTab.Value])
	assert_eq(bar.selected(), GameTab.Value.MAP)
	assert_false(bar.button(GameTab.Value.BASE).button_pressed)


func test_a_touch_on_the_lit_tab_tells_it_too_and_keeps_it_lit() -> void:
	var bar := _bar()
	press("Base")
	assert_eq(_chosen, [GameTab.Value.BASE] as Array[GameTab.Value])
	assert_true(bar.button(GameTab.Value.BASE).button_pressed)


func test_selects_a_tab_without_telling_it() -> void:
	var bar := _bar()
	bar.select(GameTab.Value.TECH)
	assert_eq(bar.selected(), GameTab.Value.TECH)
	assert_eq(_chosen, [] as Array[GameTab.Value])


func test_follows_the_language() -> void:
	var bar := _bar()
	use_language("en")
	assert_eq(texts(bar), PackedStringArray(["Base", "Map", "Army", "Tech"]))


func test_a_finger_finds_each_tab() -> void:
	var bar := _bar()
	for tab: GameTab.Value in GameTab.Value.values():
		assert_true(bar.button(tab).custom_minimum_size.y >= AbyssHudTheme.TOUCH_SIZE)


func _bar() -> GameTabBar:
	var bar := mount(GameTabBar.new()) as GameTabBar
	bar.tab_chosen.connect(_chosen.append)
	return bar

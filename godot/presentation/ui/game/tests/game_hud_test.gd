extends GameHudCase
## The game screen: the resource bar, the status strips, the turn row, the
## tabs and the world showing through (game_screen_test.dart,
## game_screen_tabs_test.dart, game_screen_consumption_test.dart).

const Type := ResourceType.Value


func test_shows_the_figures_of_a_new_game() -> void:
	var hud := _show()
	var resources := _game.human_player().resources
	for type: ResourceType.Value in resources:
		assert_eq(hud.resource_bar.items[type].amount_label.text, str(resources[type].amount))
	assert_eq(hud.turn_bar.turn_label.text, "Tour 1")
	assert_eq(texts(hud.tab_bar), PackedStringArray(["Base", "Carte", "Armée", "Tech"]))
	assert_no_raw_keys()


func test_shows_the_production_and_the_consumption_of_the_end_of_turn() -> void:
	var hud := _show(_game_with({BuildingType.Value.HEADQUARTERS: 1, BuildingType.Value.SOLAR_PANEL: 1}))
	var human := _game.human_player()
	var production := TurnFigures.production(_game, human)
	assert_true(production[Type.ENERGY] > 0)
	assert_eq(hud.resource_bar.items[Type.ENERGY].rate_label.text, "+%d/-4/t" % production[Type.ENERGY])


func test_shows_the_algae_the_units_eat() -> void:
	var game := GameFactory.new_single_player("Nemo", 1)
	game.human_player().units_per_level[1][UnitType.Value.SCOUT].count = 10
	var hud := _show(game)
	assert_true(hud.resource_bar.items[Type.ALGAE].rate_label.text.ends_with("/-10/t"))


func test_flags_the_energy_that_runs_short() -> void:
	var hud := _show(_game_with({BuildingType.Value.HEADQUARTERS: 1}))
	assert_true(hud.resource_bar.is_short(Type.ENERGY))
	assert_eq(hud.resource_bar.items[Type.ENERGY].rate_label.get_theme_color(&"font_color"),
		AbyssColors.ERROR)
	assert_false(hud.resource_bar.is_short(Type.ALGAE))


func test_redraws_the_figures_and_the_turn_after_a_change() -> void:
	var hud := _show()
	_game.human_player().resources[Type.CORAL].amount -= 25
	_game.turn = 2
	hud.refresh()
	assert_eq(hud.resource_bar.items[Type.CORAL].amount_label.text,
		str(_game.human_player().resources[Type.CORAL].amount))
	assert_true(hud.resource_bar.items[Type.CORAL].amount_label.is_flashing())
	assert_eq(hud.turn_bar.turn_label.text, "Tour 2")


func test_starts_on_the_base_with_the_world_showing_through() -> void:
	var hud := _show()
	assert_eq(hud.tab, GameTab.Value.BASE)
	assert_eq(hud.tab_bar.selected(), GameTab.Value.BASE)
	assert_eq(hud.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(hud.content.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_false(hud.page.visible)
	assert_eq(hud.content.size_flags_vertical, Control.SIZE_EXPAND_FILL)


func test_a_tab_covers_the_world_with_its_page_and_tells_the_view_to_show() -> void:
	var hud := _show()
	press("Carte")
	assert_eq(_tabs, [GameTab.Value.MAP] as Array[GameTab.Value])
	assert_eq(hud.tab, GameTab.Value.MAP)
	assert_false(hud.page.visible, "the map shows through")
	assert_false(hud.tech_tab.visible)
	press("Tech")
	assert_true(hud.page.visible)
	assert_true(hud.tech_tab.visible, "the research tree is the page of this tab")
	press("Base")
	assert_false(hud.page.visible)
	assert_false(hud.tech_tab.visible)
	assert_eq(_tabs, [GameTab.Value.MAP, GameTab.Value.TECH, GameTab.Value.BASE] as Array[GameTab.Value])


func test_the_tab_on_show_is_not_told_again() -> void:
	_show()
	press("Base")
	assert_eq(_tabs, [] as Array[GameTab.Value])


func test_a_tab_can_be_shown_from_outside() -> void:
	var hud := _show()
	hud.show_tab(GameTab.Value.ARMY)
	assert_eq(hud.tab_bar.selected(), GameTab.Value.ARMY)
	assert_eq(_tabs, [GameTab.Value.ARMY] as Array[GameTab.Value])
	assert_false(hud.page.visible, "the parade ground shows through")


func test_the_next_turn_button_only_asks_for_the_end_of_the_turn() -> void:
	_show()
	press("Tour suivant")
	assert_eq(_end_turns, 1)
	assert_eq(_game.turn, 1, "the flow behind it is another lot's")


func test_follows_the_language_in_the_bars() -> void:
	var hud := _show()
	use_language("en")
	assert_eq(hud.turn_bar.turn_label.text, "Turn 1")
	assert_eq(texts(hud.tab_bar), PackedStringArray(["Base", "Map", "Army", "Tech"]))


func test_has_the_status_strips_under_the_resource_bar() -> void:
	var hud := _show()
	assert_eq(hud.status_bars.get_index(), hud.resource_bar.get_index() + 1)
	assert_false(hud.status_bars.bars().is_empty(), "the lots of the threats and the events add their strips")
	assert_eq(hud.status_bars.bars().filter(func(each: Control) -> bool: return each is EventStatusBar).size(), 1)

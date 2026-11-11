extends TextsTestCase
## The tabs of the game screen: their names and icons.


func test_the_tabs_are_the_four_of_the_bottom_bar_in_order() -> void:
	assert_eq(GameTab.Value.values(), [0, 1, 2, 3])
	assert_eq(GameTab.label(GameTab.Value.BASE), "Base")
	assert_eq(GameTab.label(GameTab.Value.MAP), "Carte")
	assert_eq(GameTab.label(GameTab.Value.ARMY), "Armée")
	assert_eq(GameTab.label(GameTab.Value.TECH), "Tech")


func test_every_tab_has_a_name_in_every_language() -> void:
	assert_every_value_translated(GameTab.Value, func(tab: int) -> String:
		return GameTab.KEYS[tab])


func test_every_tab_has_an_icon() -> void:
	for tab: GameTab.Value in GameTab.Value.values():
		assert_true(ResourceLoader.exists(GameTab.icon_path(tab)), str(tab))

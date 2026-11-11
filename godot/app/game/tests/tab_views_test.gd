extends TestCase
## What the world shows behind each tab of the game screen.


func test_the_base_the_map_and_the_army_have_a_view_of_the_world() -> void:
	assert_eq(TabViews.of(GameTab.Value.BASE), WorldHost.View.BASE)
	assert_eq(TabViews.of(GameTab.Value.MAP), WorldHost.View.MAP)
	assert_eq(TabViews.of(GameTab.Value.ARMY), WorldHost.View.PARADE)


func test_the_research_covers_the_world() -> void:
	assert_eq(TabViews.of(GameTab.Value.TECH), WorldHost.View.NONE)


func test_the_tabs_the_world_shows_through_are_those_with_a_view() -> void:
	for tab: GameTab.Value in GameTab.Value.values():
		assert_eq(GameHud.WORLD_TABS.has(tab), TabViews.of(tab) != WorldHost.View.NONE)

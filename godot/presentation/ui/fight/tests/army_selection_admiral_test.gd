extends UiTestCase
## test/presentation/screens/game/fight/transition_army_selection_screen_test.dart:
## an assault is led by an Abyss Admiral, the page launches only with one.

const Scout := UnitType.Value.SCOUT
const Admiral := UnitType.Value.ABYSS_ADMIRAL

var _heard: Array[Dictionary] = []


func _page(needs_admiral := true) -> ArmySelection:
	var player := ActionSamples.fight_player({Scout: 3, Admiral: 1})
	var page := ArmySelection.new(Texts.t.bind(&"fightPrepare"), player.units_on_level(1),
		ArmySelectionSummary.boost_of(player), &"fightLaunchAssault",
		func(_picks: Dictionary[UnitType.Value, int]) -> ActionResult: return ActionResult.success(),
		null, needs_admiral)
	page.picks_changed.connect(_heard.append)
	modals().open(page)
	return page


func test_the_warning_shows_from_the_start_and_launch_waits_for_the_admiral() -> void:
	var page := _page()
	assert_true(page.actions_bar.admiral_label.visible)
	page.rows[Scout].set_value(2)
	assert_true(page.actions_bar.admiral_label.visible)
	assert_true(page.actions_bar.launch_button.disabled)
	page.rows[Admiral].set_value(1)
	assert_false(page.actions_bar.admiral_label.visible)
	assert_false(page.actions_bar.launch_button.disabled)
	page.rows[Admiral].set_value(0)
	assert_true(page.actions_bar.launch_button.disabled)
	assert_no_raw_keys(page)


func test_a_page_without_the_rule_never_warns() -> void:
	var page := _page(false)
	assert_false(page.actions_bar.admiral_label.visible)
	page.rows[Scout].set_value(1)
	assert_false(page.actions_bar.launch_button.disabled)


func test_the_picks_are_told_for_a_plan_to_follow() -> void:
	var page := _page()
	page.rows[Scout].set_value(2)
	page.rows[Admiral].set_value(1)
	assert_eq(_heard.size(), 2)
	assert_eq(_heard[1], {Scout: 2, Admiral: 1} as Dictionary[UnitType.Value, int])

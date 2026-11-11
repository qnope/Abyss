extends AssaultPlanCase
## test/presentation/screens/game/game_screen_assault_plan_test.dart: the plan
## of the assault on the target of a cell, for a sheet and for a selection.

const STOCK: Dictionary[UnitType.Value, int] = {Admiral: 1, Guardian: 4, Harpoonist: 10, UnitType.Value.SCOUT: 3}


func test_the_plan_of_a_cell_with_nothing_to_capture_is_none() -> void:
	var game := SiegeSamples.attack_game(STOCK, TransitionBaseType.Value.FAILLE, "someone")
	assert_null(AssaultPlans.plan_at(game, 1, 1, 1, {}), "a post already held")
	assert_null(AssaultPlans.plan_at(game, 1, 3, 3, {}), "a plain cell")
	assert_null(AssaultPlans.sheet_panel(game, 1, 1, 1))
	assert_null(AssaultPlans.selection_panel(game, 1, 3, 3))


func test_the_sheet_plan_sends_every_unit_of_the_level() -> void:
	var game := SiegeSamples.attack_game(STOCK)
	var panel := AssaultPlans.sheet_panel(game, 1, 1, 1)
	assert_eq(panel.plan.target, AssaultTarget.Value.FAILLE)
	assert_eq(panel.plan.army, {Admiral: 1, Guardian: 4, Harpoonist: 10, UnitType.Value.SCOUT: 3})
	assert_eq(panel.level, 1)
	assert_eq(panel.admiral_row.state, OK)
	mount(panel)
	assert_no_raw_keys(panel)


func test_the_kernel_has_a_plan_whatever_cell_of_the_volcano_is_touched() -> void:
	var game := SiegeSamples.kernel_game(STOCK)
	var panel := mount(AssaultPlans.sheet_panel(game, 3, 1, 1)) as AssaultPlanPanel
	assert_eq(panel.plan.target, AssaultTarget.Value.KERNEL)
	assert_false(panel.next_row.visible)


func test_the_selection_plan_starts_with_no_unit_and_follows_the_picks() -> void:
	var game := SiegeSamples.attack_game(STOCK)
	var panel := AssaultPlans.selection_panel(game, 1, 1, 1)
	var page := AssaultSelections.transition(game.human_player(), 1, game.levels[1].cell_at(1, 1).transition_base,
		func(_picks: Dictionary[UnitType.Value, int]) -> ActionResult: return ActionResult.success(), panel)
	AssaultPlans.track(page, panel, game, 1, 1, 1)
	modals().open(page)
	assert_eq(panel.plan.army, {})
	assert_eq(panel.admiral_row.state, MISSING)
	page.rows[Admiral].set_value(1)
	assert_eq(panel.plan.army, {Admiral: 1})
	assert_eq(panel.admiral_row.state, OK)
	assert_eq(panel.covered_row.state, WARNING)
	page.rows[Guardian].set_value(4)
	assert_eq(panel.covered_row.state, OK)
	page.rows[Admiral].set_value(0)
	assert_eq(panel.plan.army, {Guardian: 4})
	assert_eq(panel.admiral_row.state, MISSING)


func test_a_page_without_a_plan_tracks_nothing() -> void:
	var game := SiegeSamples.attack_game(STOCK)
	var page := ArmySelection.new(Texts.t.bind(&"fightPrepare"), game.human_player().units_on_level(1),
		ArmySelectionSummary.boost_of(game.human_player()), &"fightLaunch",
		func(_picks: Dictionary[UnitType.Value, int]) -> ActionResult: return ActionResult.success())
	AssaultPlans.track(page, null, game, 1, 1, 1)
	assert_eq(page.picks_changed.get_connections().size(), 0)
	page.free()


func test_a_plan_whose_target_was_taken_meanwhile_is_left_as_it_was() -> void:
	var game := SiegeSamples.attack_game(STOCK)
	var panel := AssaultPlans.selection_panel(game, 1, 1, 1)
	game.levels[1].cell_at(1, 1).transition_base.captured_by = game.human_player().id
	AssaultPlans.follow({Admiral: 1}, panel, game, 1, 1, 1)
	assert_eq(panel.plan.army, {})
	panel.free()

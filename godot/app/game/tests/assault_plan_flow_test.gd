extends PostControllerCase
## game_screen_assault_plan_test.dart: the plan of the assault on a Faille or
## on the volcano, in the sheet and in the selection that follows it.


func _plan_in(root: Node) -> AssaultPlanPanel:
	var found := find_type("AssaultPlanPanel", root)
	return found[0] as AssaultPlanPanel if not found.is_empty() else null


func test_the_sheet_of_a_guarded_faille_shows_the_plan_of_every_unit_of_the_level() -> void:
	world.map.cell_tapped.emit(1, faille_at.x, faille_at.y)
	var plan := _plan_in(current_modal())
	assert_not_null(plan)
	assert_eq(plan.plan.target, AssaultTarget.Value.FAILLE)
	assert_eq(plan.plan.army.get(Admiral), 1)
	assert_eq(plan.plan.army.get(Harpoonist), 150)
	assert_eq(plan.admiral_row.state, AssaultCheckRow.State.OK)
	assert_no_raw_keys(current_modal())


func test_the_selection_starts_with_no_unit_and_the_plan_follows_the_picks() -> void:
	var page := open_assault()
	var plan := _plan_in(page)
	assert_eq(plan.plan.army, {})
	assert_eq(plan.admiral_row.state, AssaultCheckRow.State.MISSING)
	page.rows[Admiral].set_value(1)
	page.rows[Guardian].set_value(4)
	assert_eq(plan.plan.army, {Admiral: 1, Guardian: 4})
	assert_eq(plan.admiral_row.state, AssaultCheckRow.State.OK)
	assert_eq(plan.covered_row.state, AssaultCheckRow.State.OK)
	page.rows[Harpoonist].set_value(150)
	assert_eq(plan.gauge.rating_label.text.split(" · ")[0], "Élevées")
	assert_false(page.actions_bar.admiral_label.visible)


func test_a_captured_faille_has_no_plan() -> void:
	hold_faille()
	world.map.cell_tapped.emit(1, faille_at.x, faille_at.y)
	assert_null(_plan_in(current_modal()))


func test_the_sheet_and_the_selection_of_the_volcano_show_its_plan() -> void:
	world.map.cell_tapped.emit(VOLCANO, kernel_at.x, kernel_at.y)
	var plan := _plan_in(current_modal())
	assert_eq(plan.plan.target, AssaultTarget.Value.KERNEL)
	assert_false(plan.next_row.visible, "the kernel opens no passage")
	press("Lancer l'assaut")
	var page := current_modal() as ArmySelection
	var follower := _plan_in(page)
	assert_eq(follower.plan.army, {})
	page.rows[Admiral].set_value(1)
	assert_eq(follower.plan.army, {Admiral: 1})
	assert_no_raw_keys(page)


func test_a_volcano_the_player_holds_has_no_plan() -> void:
	hold_kernel(1)
	world.map.cell_tapped.emit(VOLCANO, kernel_at.x, kernel_at.y)
	assert_null(_plan_in(current_modal()))

extends AssaultPlanCase
## test/presentation/widgets/fight/assault_plan_panel_advice_test.dart: what
## comes after the capture, and the army the plan advises.


func test_the_next_step_warns_when_the_headquarters_are_too_low() -> void:
	var row := panel_of(plan(STRONG)).next_row
	assert_true(row.visible)
	assert_eq(row.state, WARNING)
	assert_eq(row.title_label.text, "Ensuite : Module de Descente")
	assert_eq(row.detail_label.text, "Il demande le QG 5, tu es au QG 4")


func test_the_next_step_is_ok_when_the_headquarters_allow_it() -> void:
	var row := panel_of(plan(STRONG, AssaultTarget.Value.FAILLE, null, 5)).next_row
	assert_eq(row.state, OK)
	assert_eq(row.detail_label.text, "Ton QG 5 le permet déjà")


func test_the_next_step_is_absent_for_the_kernel() -> void:
	var panel := panel_of(plan(STRONG, AssaultTarget.Value.KERNEL, null, 4, 1))
	assert_false(panel.next_row.visible)
	assert_null(find_text("Ensuite : Module de Descente"))


func test_the_advice_names_the_escort_and_the_harpoonists() -> void:
	var panel := panel_of(plan({Admiral: 1, Guardian: 4, Harpoonist: 2}))
	assert_true(panel.advice_label.visible)
	assert_eq(panel.advice_label.text, "Conseil : l'Amiral avec 4 gardiens, 10 harponneurs")


func test_the_advice_is_harpoonists_alone_without_guardians() -> void:
	var panel := panel_of(plan({Harpoonist: 2}, AssaultTarget.Value.FAILLE, {}))
	assert_true(panel.advice_label.text.begins_with("Conseil : l'Amiral avec"))
	assert_false(panel.advice_label.text.contains("gardien"))


func test_the_advice_is_absent_when_out_of_reach() -> void:
	var panel := panel_of(plan(STRONG, AssaultTarget.Value.KERNEL, null, 4, 1))
	assert_false(panel.advice_label.visible)
	assert_eq(panel.advice_label.text, "")


func test_the_advice_names_several_admirals() -> void:
	var panel := panel_of(plan({Admiral: 2, Harpoonist: 2}))
	assert_true(panel.advice_label.text.begins_with("Conseil : les 2 Amiraux avec"))


func test_the_panel_shows_another_plan_when_given_one() -> void:
	var panel := panel_of(plan({Harpoonist: 2}))
	assert_eq(panel.admiral_row.state, MISSING)
	panel.show_plan(plan(STRONG))
	assert_eq(panel.admiral_row.state, OK)
	assert_eq(panel.gauge.chance.wins, 19)

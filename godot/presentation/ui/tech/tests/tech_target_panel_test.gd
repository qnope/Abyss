extends TechTestCase
## What a touch on a branch or a node opens (tech_target_panel_choice_test.dart,
## tech_target_panel_l10n_test.dart).

const A := TechOption.Value.A
const B := TechOption.Value.B

var _acted: Array[TechOption.Value] = []


func _panel(branch: TechBranch.Value, level := 0) -> TechTargetPanel:
	var panel := TechTargetPanel.new(view(), TechTarget.new(branch, level))
	panel.act_pressed.connect(_acted.append)
	return mount(panel) as TechTargetPanel


func test_a_branch_to_unlock_shows_its_cost_and_a_lit_button() -> void:
	set_lab(1)
	fill_stores()
	var panel := _panel(Branch.MILITARY)
	assert_eq(panel.header.title_label.text, "Militaire")
	assert_not_null(panel.cost_row)
	assert_eq(panel.cost_row.amounts[ResourceType.Value.ORE].text, "30")
	assert_null(panel.surcharge_label)
	assert_null(panel.status_label)
	press("Débloquer")
	assert_eq(_acted, [A] as Array[TechOption.Value])


func test_without_a_laboratory_it_says_so_and_the_button_is_dark() -> void:
	var panel := _panel(Branch.MILITARY)
	assert_eq(panel.status_label.text, "Laboratoire niveau 1 requis")
	assert_eq(panel.status_label.get_theme_color(&"font_color"), AbyssColors.WARNING)
	assert_null(panel.cost_row)
	assert_true(panel.header.act_button.disabled)


func test_a_second_branch_costs_more_and_says_so() -> void:
	set_lab(1)
	fill_stores()
	research(Branch.RESOURCES, 0)
	var panel := _panel(Branch.MILITARY)
	assert_eq(panel.surcharge_label.text, "Toutes les recherches coûteront ×1,5 une fois cette branche ouverte.")
	assert_eq(panel.cost_row.amounts[ResourceType.Value.ORE].text, "45")
	use_language("en")
	assert_eq(_panel(Branch.MILITARY).surcharge_label.text,
		"All research will cost ×1.5 once this branch is open.")


func test_a_cost_the_stock_cannot_pay_is_red_and_the_button_dark() -> void:
	set_lab(1)
	human.resources[ResourceType.Value.ORE].amount = 10
	var panel := _panel(Branch.MILITARY)
	assert_eq(panel.cost_row.amounts[ResourceType.Value.ORE].get_theme_color(&"font_color"), AbyssColors.ERROR)
	assert_true(panel.header.act_button.disabled)


func test_a_tier_acts_with_the_first_option() -> void:
	set_lab(3)
	fill_stores()
	research(Branch.MILITARY, 2, [A] as Array[int])
	var panel := _panel(Branch.MILITARY, 3)
	assert_null(panel.choice_row)
	press("Rechercher")
	assert_eq(_acted, [A] as Array[TechOption.Value])


func test_a_choice_node_offers_two_buttons_and_acts_with_the_one_pressed() -> void:
	set_lab(3)
	fill_stores()
	research(Branch.MILITARY, 1)
	var panel := _panel(Branch.MILITARY, 2)
	assert_eq(panel.header.title_label.text, "Militaire · Niveau 2 · Choix")
	assert_null(panel.header.act_button)
	assert_eq(texts(panel).count("Choisir"), 2)
	press(panel.choice_row.cards[B].choose_button)
	press(panel.choice_row.cards[A].choose_button)
	assert_eq(_acted, [B, A] as Array[TechOption.Value])


func test_a_blocked_choice_disables_both_options() -> void:
	set_lab(3)
	fill_stores()
	research(Branch.MILITARY, 1)
	human.worksite.research = 1
	var panel := _panel(Branch.MILITARY, 2)
	assert_true(panel.choice_row.cards[A].choose_button.disabled)
	assert_true(panel.choice_row.cards[B].choose_button.disabled)
	assert_eq(panel.status_label.text, "Une recherche par tour : attends le prochain tour")


func test_a_choice_made_shows_the_option_taken_and_that_it_is_acquired() -> void:
	set_lab(5)
	research(Branch.MILITARY, 4, [A, B] as Array[int])
	var panel := _panel(Branch.MILITARY, 4)
	assert_eq(panel.choice_row.cards[B].status, TechOptionCard.Status.TAKEN)
	assert_eq(panel.choice_row.cards[A].status, TechOptionCard.Status.DISCARDED)
	assert_eq(panel.status_label.text, "Acquis ✓")
	assert_eq(panel.status_label.get_theme_color(&"font_color"), AbyssColors.SUCCESS)
	assert_null(find_text("Choisir"))


func test_a_node_done_is_acquired_with_no_button() -> void:
	set_lab(5)
	research(Branch.EXPLORER, 3, [A] as Array[int])
	var panel := _panel(Branch.EXPLORER, 1)
	assert_eq(panel.status_label.text, "Acquis ✓")
	assert_null(panel.header.act_button)
	assert_null(panel.cost_row)


func test_a_node_behind_its_previous_level_says_which() -> void:
	set_lab(5)
	research(Branch.MILITARY, 1)
	assert_eq(_panel(Branch.MILITARY, 3).status_label.text, "Recherche d'abord le niveau 2")
	assert_eq(_panel(Branch.RESOURCES, 1).status_label.text, "Débloque d'abord la branche")


func test_a_node_above_the_laboratory_says_which_level_it_needs() -> void:
	set_lab(3)
	research(Branch.MILITARY, 3, [A, A] as Array[int])
	assert_eq(_panel(Branch.MILITARY, 4).status_label.text, "Laboratoire niveau 4 requis")


func test_follows_the_language() -> void:
	set_lab(1)
	research(Branch.MILITARY, 1)
	use_language("es")
	var panel := _panel(Branch.MILITARY, 2)
	assert_eq(panel.status_label.text, "Laboratorio nivel 2 necesario")
	assert_no_raw_keys(panel)
	assert_not_null(find_text("Elegir", panel))

extends TechTestCase
## Unlocking and researching from the sheet (game_screen_tech_actions_test.dart):
## the game changes through the actions, the sheet closes.

const A := TechOption.Value.A
const B := TechOption.Value.B

var _acted := 0
var _results: Array[Variant] = []


func after_each() -> void:
	if actions.acted.is_connected(_count):
		actions.acted.disconnect(_count)
	_acted = 0
	_results.clear()


func _count(_result: Variant) -> void:
	_acted += 1


func open_sheet(branch: TechBranch.Value, level := 0) -> TechTargetSheet:
	actions.acted.connect(_count)
	var sheet := TechTargetSheet.new(actions, TechTarget.new(branch, level))
	sheet.closed.connect(_results.append)
	modals().open(sheet)
	return sheet


func test_unlocks_the_branch_pays_for_it_and_closes_with_the_result() -> void:
	set_lab(1)
	fill_stores()
	var ore: int = human.resources[ResourceType.Value.ORE].amount
	var sheet := open_sheet(Branch.MILITARY)
	press("Débloquer")
	assert_true(human.tech_branches[Branch.MILITARY].unlocked)
	assert_eq(human.resources[ResourceType.Value.ORE].amount, ore - 30)
	assert_eq(_acted, 1, "told once, for the owner to save and redraw")
	assert_eq(_results.size(), 1)
	var result: ActionResult = _results[0]
	assert_true(result.is_success)
	assert_true(sheet.is_closed())
	assert_null(current_modal())


func test_researches_a_tier_and_spends_the_turns_research() -> void:
	set_lab(1)
	fill_stores()
	research(Branch.EXPLORER, 0)
	open_sheet(Branch.EXPLORER, 1)
	press("Rechercher")
	assert_eq(human.tech_branches[Branch.EXPLORER].research_level, 1)
	assert_eq(human.worksite.research, 1)
	assert_eq(_acted, 1)
	assert_null(current_modal())


func test_researches_the_option_chosen_on_a_choice_node() -> void:
	set_lab(2)
	fill_stores()
	research(Branch.EXPLORER, 1)
	var sheet := open_sheet(Branch.EXPLORER, 2)
	press(sheet.panel.choice_row.cards[B].choose_button)
	var state := human.tech_branches[Branch.EXPLORER]
	assert_eq(state.research_level, 2)
	assert_eq(state.option_at(2), B)
	assert_true(sheet.is_closed())


func test_the_first_option_on_a_choice_node_too() -> void:
	set_lab(2)
	fill_stores()
	research(Branch.EXPLORER, 1)
	var sheet := open_sheet(Branch.EXPLORER, 2)
	press(sheet.panel.choice_row.cards[A].choose_button)
	assert_eq(human.tech_branches[Branch.EXPLORER].option_at(2), A)


func test_a_button_that_cannot_be_pressed_changes_nothing() -> void:
	set_lab(1)
	var sheet := open_sheet(Branch.MILITARY)
	for resource: GameResource in human.resources.values():
		resource.amount = 0
	sheet.refresh()
	assert_true(UiButtons.under(find_text("Débloquer")).disabled)
	assert_eq(_acted, 0)
	assert_false(sheet.is_closed())


func test_a_node_done_is_only_told() -> void:
	set_lab(2)
	research(Branch.MILITARY, 1)
	var sheet := open_sheet(Branch.MILITARY, 1)
	assert_not_null(find_text("Acquis ✓", sheet))
	assert_null(find_text("Rechercher", sheet))


func test_is_built_again_on_the_language() -> void:
	set_lab(1)
	var sheet := open_sheet(Branch.MILITARY)
	use_language("en")
	assert_not_null(find_text("Military", sheet))
	assert_not_null(find_text("Unlock", sheet))
	assert_no_raw_keys(sheet)

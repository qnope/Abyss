extends TechTestCase
## The laboratory tab: the tree, the sheet a touch opens, the tree built again
## after a change (game_screen_tabs.dart, tech_tree_view_test.dart).

const A := TechOption.Value.A
const B := TechOption.Value.B

var _tab: TechTab


func _show() -> TechTab:
	_tab = mount(TechTab.new(actions, modals())) as TechTab
	return _tab


func test_shows_the_tree_of_the_game() -> void:
	set_lab(2)
	research(Branch.MILITARY, 1)
	var tab := _show()
	assert_eq(tab.tree.node_at(Branch.MILITARY, 1).state, TechNodeState.Value.RESEARCHED)
	assert_eq(tab.tree.node_at(Branch.MILITARY, 2, A).state, TechNodeState.Value.ACCESSIBLE)
	assert_eq(tab.tree.columns[Branch.EXPLORER].medallion.unlocked, false)
	assert_not_null(find_text("Militaire", tab))
	assert_no_raw_keys(tab)


func test_without_a_laboratory_the_tab_says_what_to_build() -> void:
	var tab := _show()
	assert_not_null(tab.tree.notice)
	assert_not_null(find_text("Laboratoire niveau 1 requis", tab))
	assert_eq(tab.tree.lab.level_label.text, "Non construit")


func test_a_touch_on_a_node_opens_its_sheet() -> void:
	set_lab(2)
	research(Branch.MILITARY, 1)
	var tab := _show()
	press(tab.tree.node_at(Branch.MILITARY, 2, B).tap_button)
	var sheet := current_modal() as TechTargetSheet
	assert_not_null(sheet)
	assert_true(sheet.target.equals(TechTarget.new(Branch.MILITARY, 2)))
	assert_not_null(find_text("Militaire · Niveau 2 · Choix", sheet))


func test_a_touch_on_a_medallion_opens_the_sheet_to_unlock_the_branch() -> void:
	set_lab(1)
	var tab := _show()
	press(tab.tree.columns[Branch.RESOURCES].medallion.tap_button)
	var sheet := current_modal() as TechTargetSheet
	assert_true(sheet.target.is_branch())
	assert_eq(sheet.target.branch, Branch.RESOURCES)
	assert_not_null(find_text("Débloquer", sheet))


func test_a_laboratory_missing_is_told_in_the_sheet() -> void:
	var tab := _show()
	press(tab.tree.columns[Branch.MILITARY].medallion.tap_button)
	assert_not_null(find_text("Laboratoire niveau 1 requis", current_modal()))
	assert_true(UiButtons.under(find_text("Débloquer", current_modal())).disabled)


func test_the_tree_is_built_again_after_a_change() -> void:
	set_lab(1)
	fill_stores()
	var tab := _show()
	var before := tab.tree.get_instance_id()
	press(tab.tree.columns[Branch.EXPLORER].medallion.tap_button)
	press("Débloquer")
	assert_null(current_modal())
	assert_true(human.tech_branches[Branch.EXPLORER].unlocked)
	assert_eq(tab.tree.get_instance_id(), before, "the owner redraws it")
	tab.refresh()
	assert_ne(tab.tree.get_instance_id(), before)
	assert_true(tab.tree.columns[Branch.EXPLORER].medallion.unlocked)
	assert_eq(tab.tree.node_at(Branch.EXPLORER, 1).state, TechNodeState.Value.ACCESSIBLE)
	assert_eq(tab.get_child_count(), 1)


func test_follows_the_language() -> void:
	var tab := _show()
	use_language("en")
	assert_not_null(find_text("Explorer", tab))
	assert_not_null(find_text("Laboratory level 1 required", tab))
	assert_no_raw_keys(tab)

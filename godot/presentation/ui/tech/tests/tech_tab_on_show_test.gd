extends TechTestCase
## The laboratory tab builds its tree only while it is on show: hidden, a
## refresh leaves the tree as it is, and the tab builds it once when it is
## shown again, if the game or the language changed meanwhile.

var _tab: TechTab


## The tab mounted in the window, with the laboratory built.
func _mounted() -> TechTab:
	set_lab(1)
	_tab = mount(TechTab.new(actions, modals())) as TechTab
	return _tab


func _unlocked(branch: TechBranch.Value) -> bool:
	return _tab.tree.columns[branch].medallion.unlocked


func test_hidden_it_keeps_its_tree_on_refresh() -> void:
	var tab := _mounted()
	tab.visible = false
	var before := tab.tree.get_instance_id()
	research(Branch.EXPLORER, 0)
	tab.refresh()
	assert_eq(tab.tree.get_instance_id(), before, "nothing is built for a tab no one sees")
	assert_false(_unlocked(Branch.EXPLORER))


func test_shown_after_a_change_it_builds_the_tree_once() -> void:
	var tab := _mounted()
	tab.visible = false
	var before := tab.tree.get_instance_id()
	research(Branch.EXPLORER, 0)
	tab.refresh()
	tab.refresh()
	tab.visible = true
	var shown := tab.tree.get_instance_id()
	assert_ne(shown, before)
	assert_true(_unlocked(Branch.EXPLORER))
	assert_eq(tab.tree.get_parent().get_child_count(), 1, "the tree before is gone")
	tab.visible = false
	tab.visible = true
	assert_eq(tab.tree.get_instance_id(), shown, "built once")


func test_shown_with_nothing_changed_it_keeps_its_tree() -> void:
	var tab := _mounted()
	var before := tab.tree.get_instance_id()
	tab.visible = false
	tab.visible = true
	assert_eq(tab.tree.get_instance_id(), before)


func test_hidden_by_its_parent_it_waits_for_the_parent_to_show() -> void:
	var tab := _mounted()
	var before := tab.tree.get_instance_id()
	host().visible = false
	research(Branch.MILITARY, 0)
	tab.refresh()
	assert_eq(tab.tree.get_instance_id(), before)
	host().visible = true
	assert_ne(tab.tree.get_instance_id(), before)
	assert_true(_unlocked(Branch.MILITARY))


func test_hidden_through_a_change_of_language_it_is_built_in_the_new_one_when_shown() -> void:
	set_lab(0)
	_tab = mount(TechTab.new(actions, modals())) as TechTab
	_tab.visible = false
	var before := _tab.tree.get_instance_id()
	use_language("en")
	assert_eq(_tab.tree.get_instance_id(), before)
	_tab.visible = true
	assert_ne(_tab.tree.get_instance_id(), before)
	assert_not_null(find_text("Laboratory level 1 required", _tab))
	assert_null(find_text("Laboratoire niveau 1 requis", _tab))
	assert_no_raw_keys(_tab)


func test_on_show_it_builds_the_tree_at_once() -> void:
	var tab := _mounted()
	var before := tab.tree.get_instance_id()
	research(Branch.RESOURCES, 0)
	tab.refresh()
	assert_ne(tab.tree.get_instance_id(), before)
	assert_true(_unlocked(Branch.RESOURCES))


func test_out_of_the_tree_it_builds_the_tree_at_once() -> void:
	set_lab(1)
	_tab = TechTab.new(actions, modals())
	add_cleanup(_tab.free)
	assert_not_null(_tab.tree, "complete once built")
	_tab.visible = false
	var before := _tab.tree.get_instance_id()
	research(Branch.EXPLORER, 0)
	_tab.refresh()
	assert_ne(_tab.tree.get_instance_id(), before)
	assert_true(_unlocked(Branch.EXPLORER))

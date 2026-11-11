extends TechTestCase
## The tree in each state of the research (tech_tree_view_test.dart).

const State := TechNodeState.Value

var _tapped: Array[TechTarget] = []


func _tree() -> TechTreeView:
	var tree := TechTreeView.new(view())
	tree.target_tapped.connect(_tapped.append)
	return mount(tree) as TechTreeView


func _states(tree: TechTreeView, branch: TechBranch.Value) -> Array[TechNodeState.Value]:
	var found: Array[TechNodeState.Value] = []
	for node: TechNode in tree.columns[branch].nodes.values():
		found.append(node.state)
	return found


func test_a_new_game_has_no_laboratory_and_everything_locked() -> void:
	var tree := _tree()
	assert_not_null(tree.notice)
	assert_not_null(find_text("Laboratoire niveau 1 requis", tree.notice))
	assert_false(tree.lab.built)
	for branch: TechBranch.Value in TechBranch.Value.values():
		assert_false(tree.columns[branch].medallion.unlocked)
		assert_eq(_states(tree, branch).count(State.LOCKED), 7)


func test_a_laboratory_lifts_the_notice_but_not_the_locked_branches() -> void:
	set_lab(1)
	var tree := _tree()
	assert_null(tree.notice)
	assert_true(tree.lab.built)
	assert_eq(tree.lab.level_label.text, "Niveau 1")
	assert_false(tree.columns[TechBranch.Value.MILITARY].medallion.unlocked)


func test_a_tree_in_the_middle_of_a_game_shows_every_state() -> void:
	set_lab(3)
	research(Branch.MILITARY, 2, [1] as Array[int])
	research(Branch.EXPLORER, 0)
	var tree := _tree()
	assert_eq(tree.node_at(Branch.MILITARY, 1).state, State.RESEARCHED)
	assert_eq(tree.node_at(Branch.MILITARY, 2, TechOption.Value.A).state, State.DISCARDED)
	assert_eq(tree.node_at(Branch.MILITARY, 2, TechOption.Value.B).state, State.RESEARCHED)
	assert_eq(tree.node_at(Branch.MILITARY, 3).state, State.ACCESSIBLE)
	assert_eq(tree.node_at(Branch.MILITARY, 4, TechOption.Value.A).state, State.LOCKED)
	assert_eq(tree.node_at(Branch.EXPLORER, 1).state, State.ACCESSIBLE)
	assert_eq(tree.node_at(Branch.RESOURCES, 1).state, State.LOCKED)
	assert_eq(tree.columns[Branch.MILITARY].medallion.level_label.text, "Niv. 2")
	assert_true(tree.columns[Branch.EXPLORER].medallion.unlocked)


func test_tells_the_target_that_was_touched() -> void:
	set_lab(2)
	research(Branch.RESOURCES, 1)
	var tree := _tree()
	press(tree.node_at(Branch.RESOURCES, 2, TechOption.Value.B).tap_button)
	press(tree.columns[Branch.MILITARY].medallion.tap_button)
	assert_eq(_tapped.size(), 2)
	assert_true(_tapped[0].equals(TechTarget.new(Branch.RESOURCES, 2)))
	assert_true(_tapped[1].equals(TechTarget.new(Branch.MILITARY)))


func test_names_the_three_branches_in_every_language() -> void:
	var tree := _tree()
	assert_not_null(find_text("Militaire", tree))
	assert_not_null(find_text("Ressources", tree))
	assert_not_null(find_text("Explorateur", tree))
	assert_no_raw_keys(tree)
	use_language("en")
	var english := _tree()
	assert_not_null(find_text("Explorer", english))
	assert_not_null(find_text("Laboratory level 1 required", english))
	use_language("es")
	var spanish := _tree()
	assert_not_null(find_text("Exploración", spanish))
	assert_no_raw_keys(spanish)

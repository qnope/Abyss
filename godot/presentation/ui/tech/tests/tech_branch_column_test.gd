extends TechTestCase
## A branch laid out as a column: medallion, nodes and the threads between.

const State := TechNodeState.Value
const A := TechOption.Value.A
const B := TechOption.Value.B

var _tapped: Array[TechTarget] = []


func _column(branch: TechBranch.Value) -> TechBranchColumn:
	var column := TechBranchColumn.new(branch, view())
	column.target_tapped.connect(_tapped.append)
	return mount(column) as TechBranchColumn


func test_has_seven_nodes_the_choice_levels_having_two() -> void:
	var column := _column(Branch.MILITARY)
	assert_eq(column.nodes.keys(), ["1", "2a", "2b", "3", "4a", "4b", "5"] as Array)
	assert_eq(column.node_at(2, B).level, 2)
	assert_eq(column.node_at(2, B).option, B)
	assert_null(column.node_at(2), "a choice level has no node without option")
	assert_null(column.node_at(3).option)


func test_a_locked_branch_has_its_nodes_locked_and_its_threads_dim() -> void:
	var column := _column(Branch.MILITARY)
	assert_false(column.medallion.unlocked)
	for node: TechNode in column.nodes.values():
		assert_eq(node.state, State.LOCKED)
	for link: TechLink in column.links:
		assert_false(link.lit)


func test_the_nodes_stand_as_the_research_does() -> void:
	set_lab(2)
	research(Branch.MILITARY, 2, [B] as Array[int])
	var column := _column(Branch.MILITARY)
	assert_eq(column.node_at(1).state, State.RESEARCHED)
	assert_eq(column.node_at(2, A).state, State.DISCARDED)
	assert_eq(column.node_at(2, B).state, State.RESEARCHED)
	assert_eq(column.node_at(3).state, State.LOCKED, "the laboratory is too low")
	set_lab(3)
	assert_eq(_column(Branch.MILITARY).node_at(3).state, State.ACCESSIBLE)


func test_the_threads_are_lit_as_far_as_the_research_went() -> void:
	research(Branch.EXPLORER, 2, [A] as Array[int])
	var lit: Array[bool] = []
	for link: TechLink in _column(Branch.EXPLORER).links:
		lit.append(link.lit)
	assert_eq(lit, [true, true, true, false, false] as Array[bool])
	assert_eq(_column(Branch.EXPLORER).links[0].color, Color(AbyssColors.BIOLUM_CYAN, TechLink.LIT_ALPHA))


func test_a_touch_on_a_node_tells_its_branch_and_level() -> void:
	var column := _column(Branch.RESOURCES)
	press(column.node_at(4, B).tap_button)
	press(column.node_at(5).tap_button)
	assert_eq(_tapped.size(), 2)
	assert_true(_tapped[0].equals(TechTarget.new(Branch.RESOURCES, 4)))
	assert_true(_tapped[1].equals(TechTarget.new(Branch.RESOURCES, 5)))


func test_a_touch_on_the_medallion_tells_the_branch() -> void:
	press(_column(Branch.EXPLORER).medallion.tap_button)
	assert_eq(_tapped.size(), 1)
	assert_true(_tapped[0].is_branch())
	assert_eq(_tapped[0].branch, Branch.EXPLORER)

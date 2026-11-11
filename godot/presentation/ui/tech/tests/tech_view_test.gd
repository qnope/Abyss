extends TechTestCase
## What the tree reads of the game: how each node stands, what blocks a
## target, what it costs (tech_reef.dart: nodeState, tech_target_panel.dart).

const State := TechNodeState.Value
const A := TechOption.Value.A
const B := TechOption.Value.B


func test_a_locked_branch_has_only_locked_nodes() -> void:
	set_lab(5)
	for level in range(1, 6):
		assert_eq(view().node_state(Branch.MILITARY, level), State.LOCKED)
	assert_false(view().is_unlocked(Branch.MILITARY))


func test_the_next_node_is_accessible_once_the_laboratory_is_high_enough() -> void:
	research(Branch.MILITARY, 1)
	set_lab(1)
	assert_eq(view().node_state(Branch.MILITARY, 2, A), State.LOCKED, "level 2 needs a laboratory 2")
	set_lab(2)
	assert_eq(view().node_state(Branch.MILITARY, 2, A), State.ACCESSIBLE)
	assert_eq(view().node_state(Branch.MILITARY, 2, B), State.ACCESSIBLE)
	assert_eq(view().node_state(Branch.MILITARY, 3), State.LOCKED, "only the next one")


func test_the_nodes_reached_are_researched_and_the_option_left_is_discarded() -> void:
	set_lab(5)
	research(Branch.EXPLORER, 4, [B, A] as Array[int])
	var view := view()
	assert_eq(view.node_state(Branch.EXPLORER, 1), State.RESEARCHED)
	assert_eq(view.node_state(Branch.EXPLORER, 2, A), State.DISCARDED)
	assert_eq(view.node_state(Branch.EXPLORER, 2, B), State.RESEARCHED)
	assert_eq(view.node_state(Branch.EXPLORER, 4, A), State.RESEARCHED)
	assert_eq(view.node_state(Branch.EXPLORER, 4, B), State.DISCARDED)
	assert_eq(view.node_state(Branch.EXPLORER, 5), State.ACCESSIBLE)


func test_a_choice_recorded_nowhere_is_the_first_option() -> void:
	research(Branch.MILITARY, 2)
	assert_eq(view().node_state(Branch.MILITARY, 2, A), State.RESEARCHED)
	assert_eq(view().node_state(Branch.MILITARY, 2, B), State.DISCARDED)


func test_a_branch_the_player_lacks_is_locked() -> void:
	human.tech_branches.erase(Branch.MILITARY)
	var view := view()
	assert_null(view.state_of(Branch.MILITARY))
	assert_eq(view.research_level(Branch.MILITARY), 0)
	assert_false(view.is_unlocked(Branch.MILITARY))
	assert_false(view.is_done(TechTarget.new(Branch.MILITARY)))


func test_a_target_is_done_when_unlocked_or_researched() -> void:
	research(Branch.RESOURCES, 2)
	var view := view()
	assert_true(view.is_done(TechTarget.new(Branch.RESOURCES)))
	assert_true(view.is_done(TechTarget.new(Branch.RESOURCES, 2)))
	assert_false(view.is_done(TechTarget.new(Branch.RESOURCES, 3)))
	assert_false(view.is_done(TechTarget.new(Branch.MILITARY)))


func test_the_blockers_in_the_order_they_are_told() -> void:
	var view := view()
	assert_eq(view.blocker(TechTarget.new(Branch.MILITARY)), "Laboratoire niveau 1 requis")
	assert_eq(view.blocker(TechTarget.new(Branch.MILITARY, 1)), "Débloque d'abord la branche")
	set_lab(5)
	research(Branch.MILITARY, 1)
	assert_eq(view().blocker(TechTarget.new(Branch.MILITARY, 3)), "Recherche d'abord le niveau 2")
	set_lab(1)
	assert_eq(view().blocker(TechTarget.new(Branch.MILITARY, 2)), "Laboratoire niveau 2 requis")
	set_lab(2)
	assert_eq(view().blocker(TechTarget.new(Branch.MILITARY, 2)), "")
	human.worksite.research = 1
	assert_eq(view().blocker(TechTarget.new(Branch.MILITARY, 2)), "Une recherche par tour : attends le prochain tour")
	assert_eq(view().blocker(TechTarget.new(Branch.RESOURCES)), "", "unlocking is not a research")


func test_the_blockers_follow_the_language() -> void:
	use_language("en")
	assert_eq(view().blocker(TechTarget.new(Branch.MILITARY)), "Laboratory level 1 required")
	use_language("es")
	assert_eq(view().blocker(TechTarget.new(Branch.MILITARY, 1)), "Desbloquea primero la rama")
	assert_eq(view().blocker(TechTarget.new(Branch.MILITARY)), "Laboratorio nivel 1 necesario")


func test_a_target_can_be_acted_on_when_nothing_blocks_it_and_the_stock_is_there() -> void:
	set_lab(1)
	var target := TechTarget.new(Branch.MILITARY)
	for resource: GameResource in human.resources.values():
		resource.amount = 0
	assert_false(view().can_act(target), "the stock is short")
	fill_stores()
	assert_true(view().can_act(target))
	research(Branch.MILITARY, 0)
	assert_false(view().can_act(target), "already unlocked")
	assert_true(view().can_act(TechTarget.new(Branch.MILITARY, 1)))
	human.worksite.research = 1
	assert_false(view().can_act(TechTarget.new(Branch.MILITARY, 1)), "one research a turn")


func test_the_costs_grow_with_the_branches_opened() -> void:
	var first := view().costs(TechTarget.new(Branch.MILITARY))
	assert_eq(first, TechCostCalculator.unlock_cost(Branch.MILITARY, 0))
	assert_eq(view().surcharge_factor(), 1.0)
	research(Branch.RESOURCES, 0)
	assert_eq(view().opened, 1)
	assert_eq(view().costs(TechTarget.new(Branch.MILITARY)), TechCostCalculator.unlock_cost(Branch.MILITARY, 1))
	assert_eq(view().surcharge_factor(), 1.5)
	assert_eq(view().costs(TechTarget.new(Branch.RESOURCES, 3)), TechCostCalculator.research_cost(Branch.RESOURCES, 3, 1))
	assert_eq(view().lab_level, 0)

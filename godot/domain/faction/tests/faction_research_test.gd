extends TestCase
## test/domain/faction/faction_research_test.dart: what each personality
## researches.

const Personality := FactionPersonality.Value
const Branch := TechBranch.Value
const Option := TechOption.Value

const SEEKERS: Array[Personality] = [
	Personality.CURRENT_NOMADS, Personality.KRAKEN_FAITHFUL, Personality.MAGMA_SMITHS,
]


## Position of the `count`-th node of `branch` in `plan`.
static func _nth(plan: Array[Branch], branch: Branch, count: int) -> int:
	var seen := 0
	for i: int in plan.size():
		if plan[i] == branch:
			seen += 1
			if seen == count:
				return i
	return -1


func test_every_personality_researches_the_explorer_branch() -> void:
	for p: Personality in Personality.values():
		var plan := FactionResearch.plan_of(p)
		assert_ne(_nth(plan, Branch.EXPLORER, 2), -1, DartEnum.name_of(Personality, p))


func test_the_default_plan_opens_explorer_right_after_military_3() -> void:
	var plan := FactionResearch.plan_of(Personality.PEARL_ORDER)
	assert_eq(_nth(plan, Branch.EXPLORER, 1), _nth(plan, Branch.MILITARY, 3) + 1)
	assert_eq(_nth(plan, Branch.EXPLORER, 3), -1)


func test_the_kernel_seekers_open_explorer_earlier_and_go_to_node_3() -> void:
	var usual := FactionResearch.plan_of(Personality.PEARL_ORDER)
	for p: Personality in SEEKERS:
		var plan := FactionResearch.plan_of(p)
		var name := DartEnum.name_of(Personality, p)
		assert_eq(_nth(plan, Branch.EXPLORER, 1), _nth(plan, Branch.MILITARY, 2) + 1, name)
		assert_true(_nth(plan, Branch.EXPLORER, 1) < _nth(usual, Branch.EXPLORER, 1))
		assert_true(_nth(plan, Branch.EXPLORER, 3) > _nth(plan, Branch.RESOURCES, 3))


func test_the_factions_take_the_deep_sonar_the_monks_the_silent_swim() -> void:
	for p: Personality in Personality.values():
		var option: Option = FactionResearch.picks_of(p)[Branch.EXPLORER][0]
		assert_eq(
			TechPerk.of(Branch.EXPLORER, 2, option),
			TechPerk.Value.SILENT_SWIM if p == Personality.SILENCE_MONKS else TechPerk.Value.DEEP_SONAR,
			DartEnum.name_of(Personality, p)
		)
	assert_eq(
		FactionResearch.picks_of(Personality.PEARL_ORDER)[Branch.EXPLORER], [Option.A, Option.A]
	)

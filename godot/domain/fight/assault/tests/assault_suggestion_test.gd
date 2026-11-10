extends TestCase
## test/domain/fight/assault/assault_suggestion_test.dart: the army the
## guide advises for an assault, the fewest Harpoonists that capture.

const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL
const GUARDIAN := UnitType.Value.GUARDIAN
const HARPOONIST := UnitType.Value.HARPOONIST
const FAILLE := AssaultTarget.Value.FAILLE
const KERNEL := AssaultTarget.Value.KERNEL


func _plan(
	army: Dictionary[UnitType.Value, int],
	target := FAILLE,
	max_added := AssaultPlan.DEFAULT_MAX_HARPOONISTS,
) -> AssaultPlan:
	return AssaultPlan.of(AssaultSamples.assault_player(), 1, target, army, max_added)


func _wins(army: Dictionary[UnitType.Value, int]) -> int:
	return _plan(army).chance().wins


func _suggested(plan: AssaultPlan) -> int:
	var harpoonists: int = plan.suggested_harpoonists()
	return harpoonists


func _instrumented() -> bool:
	for entry: Dictionary in ProjectSettings.get_global_class_list():
		if entry["class"] == TestCoverageDump.PROBE_CLASS:
			return true
	return false


func _army(k: int) -> Dictionary[UnitType.Value, int]:
	return {ADMIRAL: 1, GUARDIAN: 2, HARPOONIST: k}


func test_the_fewest_harpoonists_that_win_19_rehearsals_of_20() -> void:
	var plan := _plan({ADMIRAL: 1, GUARDIAN: 2, HARPOONIST: 3})
	var needed := _suggested(plan)

	assert_eq(plan.suggested_army(), _army(needed))
	assert_true(_wins(_army(needed)) >= 19)
	assert_true(_wins(_army(needed - 1)) < 19)


func test_ignores_the_harpoonists_and_others_already_selected() -> void:
	var bare := _suggested(_plan({ADMIRAL: 1}))

	assert_eq(_plan({ADMIRAL: 1, HARPOONIST: 7, UnitType.Value.SCOUT: 3}).suggested_harpoonists(), bare)


func test_guardians_lower_the_count() -> void:
	assert_true(_suggested(_plan({ADMIRAL: 1, GUARDIAN: 6})) < _suggested(_plan({ADMIRAL: 1})))


func test_assumes_one_admiral_when_none_is_selected() -> void:
	var plan := _plan({GUARDIAN: 1})
	var suggested: Dictionary[UnitType.Value, int] = plan.suggested_army()

	assert_eq(suggested[ADMIRAL], 1)
	assert_eq(plan.suggested_harpoonists(), _plan({ADMIRAL: 1, GUARDIAN: 1}).suggested_harpoonists())


func test_the_kernel_needs_more_than_a_faille() -> void:
	assert_true(_suggested(_plan({ADMIRAL: 1}, KERNEL)) > _suggested(_plan({ADMIRAL: 1})))


func test_counts_the_military_research_of_an_attacker() -> void:
	var player := AssaultSamples.assault_player()
	player.tech_branches[TechBranch.Value.MILITARY] = TechBranchState.new(TechBranch.Value.MILITARY, true, 1)
	var researched := AssaultPlan.of(player, 1, AssaultTarget.Value.CHEMINEE, {ADMIRAL: 1})

	assert_true(_suggested(researched) < _suggested(_plan({ADMIRAL: 1}, AssaultTarget.Value.CHEMINEE)))


func test_none_when_out_of_reach_within_the_cap() -> void:
	var plan := _plan({ADMIRAL: 1}, KERNEL, 5)

	assert_null(plan.suggested_harpoonists())
	assert_null(plan.suggested_army())


func test_is_the_same_for_the_same_input() -> void:
	assert_eq(_plan({ADMIRAL: 1, GUARDIAN: 1}).suggested_harpoonists(),
		_plan({ADMIRAL: 1, GUARDIAN: 1}).suggested_harpoonists())


func test_a_plan_for_a_30_unit_army_recomputes_well_under_50_ms() -> void:
	var start := Time.get_ticks_usec()
	for k: int in 10:
		_plan({ADMIRAL: 1, GUARDIAN: 4, HARPOONIST: 25 + k}).chance()
	var per_plan := (Time.get_ticks_usec() - start) / 10.0 / 1000.0
	print("assault plan: %.1f ms per chance" % per_plan)

	# Not in the Dart file: four times the bound in the instrumented copy of
	# tool/godot_coverage.py, whose probes slow every line down.
	assert_true(per_plan < (200.0 if _instrumented() else 50.0), str(per_plan))


## Not in the Dart file: the escort keeps a lone Guardian, and a suggestion
## of no Harpoonist at all leaves them out of the army.
func test_a_suggestion_of_no_harpoonist_leaves_them_out() -> void:
	var escorted: Dictionary[UnitType.Value, int] = _plan({ADMIRAL: 2, GUARDIAN: 1}).suggested_army()
	assert_eq([escorted[ADMIRAL], escorted[GUARDIAN]], [2, 1])
	var plan := _plan({ADMIRAL: 1, GUARDIAN: 40})

	assert_eq(plan.suggested_harpoonists(), 0)
	assert_eq(plan.suggested_army(), {ADMIRAL: 1, GUARDIAN: 40})

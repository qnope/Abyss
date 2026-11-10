extends TestCase
## test/domain/fight/assault/assault_plan_test.dart: what the player should
## know before assaulting a post or the kernel with the army being composed.

const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL
const GUARDIAN := UnitType.Value.GUARDIAN
const HARPOONIST := UnitType.Value.HARPOONIST
const FAILLE := AssaultTarget.Value.FAILLE


func _plan(
	army: Dictionary[UnitType.Value, int],
	target := FAILLE,
	stock: Dictionary[UnitType.Value, int] = {},
	hq := 1,
) -> AssaultPlan:
	return AssaultPlan.of(AssaultSamples.assault_player(stock, 1, hq), 1, target, army)


func test_the_admiral_is_present_with_at_least_one_in_the_army() -> void:
	assert_true(_plan({ADMIRAL: 1}).has_admiral())
	assert_false(_plan({ADMIRAL: 0, HARPOONIST: 5}).has_admiral())


func test_the_admiral_counts_the_admirals_the_player_has_on_the_level() -> void:
	assert_eq(_plan({}, FAILLE, {ADMIRAL: 2}).admirals_available, 2)
	assert_eq(_plan({}).admirals_available, 0)


func test_the_admiral_is_covered_by_at_least_one_guardian() -> void:
	assert_true(_plan({ADMIRAL: 1, GUARDIAN: 1}).admiral_covered())
	assert_false(_plan({ADMIRAL: 1, HARPOONIST: 9}).admiral_covered())


func test_the_chance_is_none_without_an_admiral_without_rehearsing() -> void:
	assert_true(_plan({HARPOONIST: 60}).chance().equals(AssaultChance.none()))


func test_the_chance_is_high_for_a_strong_army() -> void:
	var chance := _plan({ADMIRAL: 1, GUARDIAN: 4, HARPOONIST: 40}).chance()

	assert_eq(chance.rehearsals, AssaultPlan.rehearsals())
	assert_eq(chance.rating(), AssaultRating.Value.HIGH)


func test_the_chance_is_low_for_a_weak_army() -> void:
	var chance := _plan({ADMIRAL: 1, HARPOONIST: 2}).chance()

	assert_eq(chance.rating(), AssaultRating.Value.LOW)


func test_the_chance_fights_the_kernel_guardians_on_the_kernel() -> void:
	var army: Dictionary[UnitType.Value, int] = {ADMIRAL: 1, GUARDIAN: 4, HARPOONIST: 40}

	assert_eq(_plan(army, AssaultTarget.Value.KERNEL).chance().rating(), AssaultRating.Value.LOW)


func test_the_chance_is_the_same_for_the_same_input() -> void:
	var army: Dictionary[UnitType.Value, int] = {ADMIRAL: 1, GUARDIAN: 1, HARPOONIST: 12}

	assert_true(_plan(army).chance().equals(_plan(army.duplicate()).chance()))


func test_the_next_step_is_the_module_de_descente_after_a_faille_hq_5() -> void:
	var step := _plan({}, FAILLE, {}, 4).next_step

	assert_eq(step.required_hq, 5)
	assert_eq(step.current_hq, 4)
	assert_false(step.is_ready())
	assert_true(_plan({}, FAILLE, {}, 5).next_step.is_ready())


func test_the_next_step_is_the_capsule_pressurisee_after_a_cheminee_hq_8() -> void:
	var step := _plan({}, AssaultTarget.Value.CHEMINEE, {}, 8).next_step

	assert_eq(step.building, AssaultTarget.passage(AssaultTarget.Value.CHEMINEE))
	assert_eq(step.required_hq, 8)
	assert_true(step.is_ready())


func test_the_next_step_is_none_after_the_kernel() -> void:
	assert_null(_plan({}, AssaultTarget.Value.KERNEL).next_step)


## Not in the Dart file: the army is kept without its empty entries, read
## only as Dart's unmodifiable map, and a chance is rehearsed once.
func test_keeps_the_army_without_its_empty_entries_and_its_chance_once() -> void:
	var plan := _plan({ADMIRAL: 1, GUARDIAN: 0, HARPOONIST: 3})
	assert_eq(plan.army, {ADMIRAL: 1, HARPOONIST: 3})
	assert_true(plan.army.is_read_only())
	assert_true(is_same(plan.chance(), plan.chance()))

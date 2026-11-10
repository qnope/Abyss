extends TestCase
## lib/domain/fight/assault/assault_rehearsals.dart has no Dart test of its
## own: the plan's tests (assault_plan_test.dart, assault_suggestion_test
## .dart) read it through AssaultPlan, which waits for the game module, and
## the assault vectors through chanceOf and harpoonistsFor. These hold what
## those tests check of it in the meantime. Not in the Dart files.

const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL
const GUARDIAN := UnitType.Value.GUARDIAN
const HARPOONIST := UnitType.Value.HARPOONIST
const FAILLE := AssaultTarget.Value.FAILLE


func _chance(army: Dictionary[UnitType.Value, int], boost := UnitBoost.none()) -> AssaultChance:
	return AssaultRehearsals.chance_of(army, FAILLE, boost)


func test_rehearses_with_the_planner_of_19_captures_out_of_20() -> void:
	var planner := AssaultRehearsals.planner()
	assert_eq([planner.rehearsals, planner.confidence], [20, 0.95])


func test_a_strong_army_captures_and_a_weak_one_does_not() -> void:
	var strong := _chance({ADMIRAL: 1, GUARDIAN: 4, HARPOONIST: 40})
	assert_eq(strong.rehearsals, 20)
	assert_eq(strong.rating(), AssaultRating.Value.HIGH)
	assert_eq(_chance({ADMIRAL: 1, HARPOONIST: 2}).rating(), AssaultRating.Value.LOW)


func test_remembers_an_answer_and_tells_the_boosts_apart() -> void:
	var army: Dictionary[UnitType.Value, int] = {ADMIRAL: 1, GUARDIAN: 1, HARPOONIST: 12}
	var first := _chance(army)
	assert_true(is_same(_chance(army.duplicate()), first))
	assert_false(is_same(_chance(army, UnitBoost.new(60, 60)), first))
	AssaultRehearsals.debug_reset()
	var again := _chance(army)
	assert_false(is_same(again, first))
	assert_true(again.equals(first))


func test_the_fewest_harpoonists_that_capture_19_times_out_of_20() -> void:
	var escort: Dictionary[UnitType.Value, int] = {ADMIRAL: 1, GUARDIAN: 2}
	var needed: int = AssaultRehearsals.harpoonists_for(escort, FAILLE, UnitBoost.none(), 300)
	var enough: Dictionary[UnitType.Value, int] = {ADMIRAL: 1, GUARDIAN: 2, HARPOONIST: needed}
	var one_short: Dictionary[UnitType.Value, int] = {
		ADMIRAL: 1, GUARDIAN: 2, HARPOONIST: needed - 1,
	}
	assert_true(_chance(enough).wins >= 19)
	assert_true(_chance(one_short).wins < 19)
	var capped: Variant = AssaultRehearsals.harpoonists_for(
		{ADMIRAL: 1}, AssaultTarget.Value.KERNEL, UnitBoost.none(), 5
	)
	assert_null(capped)


func test_keys_an_answer_by_all_it_depends_on() -> void:
	var key := AssaultRehearsals._key_of({HARPOONIST: 3, ADMIRAL: 1}, FAILLE, UnitBoost.new(1, 2, 3))
	assert_eq(key, "faille/0/3/0/0/1/0/1/2/3")

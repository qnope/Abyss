extends TestCase
## test/presentation/widgets/map/effects/strike/strike_timeline_test.dart.

const SWIM := 0.9
const LUNGE := MapMotion.EVENT_STEP

var _timeline := StrikeTimeline.new(SWIM, 2)


func test_it_swims_lunges_once_per_hit_settles_the_outcome_then_vanishes() -> void:
	assert_almost_eq(_timeline.total(), SWIM + LUNGE * 2 + MapMotion.FADE + MapMotion.QUICK, 1e-9)
	assert_eq(_timeline.swim_at(0.0), 0.0)
	assert_almost_eq(_timeline.swim_at(SWIM / 2.0), 0.5, 1e-9)
	assert_eq(_timeline.swim_at(SWIM), 1.0)


func test_each_hit_lands_at_the_peak_of_its_lunge() -> void:
	assert_almost_eq(_timeline.hit_at(0), SWIM + LUNGE / 2.0, 1e-9)
	assert_almost_eq(_timeline.hit_at(1), SWIM + LUNGE + LUNGE / 2.0, 1e-9)
	assert_almost_eq(_timeline.reach_at(_timeline.hit_at(0)), 1.0, 1e-9)
	assert_almost_eq(_timeline.reach_at(_timeline.hit_at(1)), 1.0, 1e-9)
	assert_almost_eq(_timeline.reach_at(SWIM), 0.0, 1e-9)
	assert_almost_eq(_timeline.reach_at(SWIM + LUNGE), 0.0, 1e-9)
	assert_eq(_timeline.reach_at(SWIM / 2.0), 0.0)


func test_the_outcome_follows_the_last_lunge_and_the_vanish_ends_it() -> void:
	var outcome := SWIM + LUNGE * 2
	assert_eq(_timeline.outcome_at(outcome), 0.0)
	assert_almost_eq(_timeline.outcome_at(outcome + MapMotion.FADE), 1.0, 1e-9)
	assert_almost_eq(_timeline.vanish_at(outcome + MapMotion.FADE), 0.0, 1e-9)
	assert_eq(_timeline.vanish_at(_timeline.total()), 1.0)


func test_without_a_swim_the_first_lunge_starts_at_once() -> void:
	var still := StrikeTimeline.new(0.0, 2)
	assert_eq(still.swim_at(0.0), 1.0)
	assert_almost_eq(still.hit_at(0), LUNGE / 2.0, 1e-9)


func test_a_long_fight_lunges_faster_to_keep_within_the_rounds_budget() -> void:
	var long := StrikeTimeline.new(SWIM, 20)
	assert_true(long.pace().lunge() < LUNGE)
	assert_true(long.pace().lunge() * 20 <= FightPace.ROUNDS_BUDGET + 1e-9)
	assert_eq(StrikeTimeline.new(SWIM, 200).pace().lunge(), FightPace.QUICKEST_LUNGE)

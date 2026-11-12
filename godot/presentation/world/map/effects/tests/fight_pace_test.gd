extends TestCase
## test/presentation/widgets/map/effects/strike/fight_pace_test.dart.

const START := 1.0
const LUNGE := MapMotion.EVENT_STEP

var _pace := FightPace.new(START, 3)


func test_its_rounds_follow_each_other_from_its_start() -> void:
	assert_eq(_pace.lunge(), LUNGE)
	assert_almost_eq(_pace.end(), START + LUNGE * 3, 1e-9)
	assert_almost_eq(_pace.hit_at(0), START + LUNGE / 2.0, 1e-9)
	assert_almost_eq(_pace.hit_at(2), START + LUNGE * 2 + LUNGE / 2.0, 1e-9)


func test_a_lunge_reaches_out_only_between_its_start_and_its_end() -> void:
	assert_eq(_pace.reach_at(START - LUNGE), 0.0)
	assert_almost_eq(_pace.reach_at(_pace.hit_at(1)), 1.0, 1e-9)
	assert_eq(_pace.reach_at(_pace.end()), 0.0)


func test_it_tells_how_long_ago_the_latest_hit_landed() -> void:
	assert_eq(_pace.since_last_hit(START), FightPace.NONE)
	assert_almost_eq(_pace.since_last_hit(_pace.hit_at(0)), 0.0, 1e-9)
	assert_almost_eq(_pace.since_last_hit(_pace.hit_at(2) + LUNGE), LUNGE, 1e-9)


func test_it_tells_how_far_a_hit_has_faded() -> void:
	assert_eq(_pace.fade_of(0, START), FightPace.NONE)
	assert_almost_eq(_pace.fade_of(0, _pace.hit_at(0)), 0.0, 1e-9)
	assert_almost_eq(_pace.fade_of(0, _pace.hit_at(0) + MapMotion.FADE / 2.0), 0.5, 1e-9)


func test_a_fight_without_rounds_takes_no_time() -> void:
	var none := FightPace.new(START, 0)
	assert_eq(none.end(), START)
	assert_eq(none.since_last_hit(START * 3.0), FightPace.NONE)


func test_a_hit_shows_until_the_next_one_lands_a_fade_at_most() -> void:
	var long := FightPace.new(START, 20)
	assert_true(long.shows_hit(0, long.hit_at(0)))
	assert_false(long.shows_hit(0, long.hit_at(1)), "the next hit takes its place")
	assert_false(long.shows_hit(19, long.hit_at(19) + MapMotion.FADE + 0.01), "a fade at most")
	assert_false(_pace.shows_hit(0, _pace.hit_at(0) - LUNGE / 4.0), "not before it lands")
	assert_true(_pace.shows_hit(2, _pace.hit_at(2) + 0.1), "the last has no next")


func test_a_long_fight_lunges_faster_to_keep_within_the_rounds_budget() -> void:
	var long := FightPace.new(START, 20)
	assert_true(long.lunge() < LUNGE)
	assert_true(long.lunge() * 20 <= FightPace.ROUNDS_BUDGET + 1e-9)
	assert_almost_eq(long.hit_at(19), START + long.lunge() * 19 + long.lunge() / 2.0, 1e-9)


func test_a_very_long_fight_never_lunges_faster_than_the_quickest_pace() -> void:
	assert_eq(FightPace.new(START, 200).lunge(), FightPace.QUICKEST_LUNGE)
	assert_eq(FightPace.lunge_for(0), LUNGE)

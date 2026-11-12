extends TestCase
## test/presentation/widgets/map/effects/story/siege_timeline_test.dart.

const ALERT := MapMotion.EVENT_STEP * 2.0
const APPROACH := MapMotion.SWIM
const LUNGE := MapMotion.EVENT_STEP

var _timeline := SiegeTimeline.new(2)


func test_the_alert_rings_the_attackers_close_in_they_clash_the_outcome_lands_and_it_rests() -> void:
	assert_almost_eq(_timeline.clashes().start, ALERT + APPROACH, 1e-9)
	assert_almost_eq(_timeline.impact(), ALERT + APPROACH + LUNGE * 2.0, 1e-9)
	assert_almost_eq(_timeline.total(), _timeline.impact() + MapMotion.FADE + MapMotion.STORY_PAUSE, 1e-9)


func test_the_alert_pulses_twice_then_goes_out() -> void:
	assert_almost_eq(_timeline.alert_at(0.0), 0.0, 1e-9)
	assert_almost_eq(_timeline.alert_at(ALERT / 4.0), 1.0, 1e-9)
	assert_almost_eq(_timeline.alert_at(ALERT / 2.0), 0.0, 1e-9)
	assert_almost_eq(_timeline.alert_at(ALERT * 3.0 / 4.0), 1.0, 1e-9)
	assert_eq(_timeline.alert_at(ALERT), 0.0)
	assert_eq(_timeline.alert_at(ALERT + 1.0), 0.0)


func test_the_attackers_close_in_after_the_alert() -> void:
	assert_eq(_timeline.approach_at(ALERT / 2.0), 0.0)
	assert_almost_eq(_timeline.approach_at(ALERT + APPROACH / 2.0), 0.5, 1e-9)
	assert_eq(_timeline.approach_at(ALERT + APPROACH), 1.0)


func test_the_outcome_follows_the_last_clash() -> void:
	assert_eq(_timeline.outcome_at(_timeline.impact()), 0.0)
	assert_almost_eq(_timeline.outcome_at(_timeline.impact() + MapMotion.FADE / 2.0), 0.5, 1e-9)
	assert_eq(_timeline.outcome_at(_timeline.total()), 1.0)


func test_a_siege_without_rounds_has_no_clash() -> void:
	var bare := SiegeTimeline.new()
	assert_eq(bare.impact(), ALERT + APPROACH)
	assert_eq(bare.rounds, 0)


func test_a_long_fight_clashes_faster() -> void:
	assert_true(SiegeTimeline.new(20).clashes().lunge() < LUNGE)

extends TestCase
## test/presentation/widgets/map/effects/map_jolt_test.dart.

const LENGTH := 0.25


func test_it_shakes_the_view_side_to_side_just_after_the_blow() -> void:
	var jolt := MapJolt.offset(0.04, LENGTH, 3.0)
	assert_ne(jolt, 0.0)
	assert_true(absf(jolt) <= 3.0)


func test_it_stays_still_before_the_blow_and_once_it_is_over() -> void:
	assert_eq(MapJolt.offset(FightPace.NONE, LENGTH, 3.0), 0.0)
	assert_eq(MapJolt.offset(-0.01, LENGTH, 3.0), 0.0)
	assert_eq(MapJolt.offset(LENGTH, LENGTH, 3.0), 0.0)

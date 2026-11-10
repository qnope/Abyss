extends TestCase
## Not in the Dart tests, which read a BaseIntel through the scouts of
## test/domain/action/spy_base (the action module): how long a report of a
## scout holds. The answers are those of lib/domain/faction/base_intel.dart.


func test_keeps_what_the_scout_saw() -> void:
	var army: Dictionary[UnitType.Value, int] = {UnitType.Value.GUARDIAN: 4}
	var stocks: Dictionary[ResourceType.Value, int] = {ResourceType.Value.PEARL: 7}
	var intel := BaseIntel.new(12, 5, 2, army, stocks)
	assert_eq([intel.turn, intel.headquarters_level, intel.rampart_level], [12, 5, 2])
	assert_eq(intel.army, army)
	assert_eq(intel.stocks, stocks)


func test_a_report_is_fresh_for_five_turns() -> void:
	var intel := _written_on(12)
	assert_eq(BaseIntel.DURATION, 5)
	assert_true(intel.is_fresh(12))
	assert_true(intel.is_fresh(17))
	assert_false(intel.is_fresh(18))


func test_counts_the_turns_a_report_has_left_never_below_zero() -> void:
	var intel := _written_on(12)
	assert_eq(intel.turns_left(12), 5)
	assert_eq(intel.turns_left(16), 1)
	assert_eq(intel.turns_left(17), 0)
	assert_eq(intel.turns_left(30), 0)


func _written_on(turn: int) -> BaseIntel:
	return BaseIntel.new(turn, 1, 0, {}, {})

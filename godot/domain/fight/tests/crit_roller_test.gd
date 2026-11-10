extends TestCase
## test/domain/fight/crit_roller_test.dart: the die that makes a hit critical.


func test_crit_roller_always_returns_false_with_crit_chance_0() -> void:
	var roller := CritRoller.new(0.0, DartRandom.new(42))
	for _i: int in 100:
		assert_false(roller.roll())


func test_crit_roller_always_returns_true_with_crit_chance_1() -> void:
	var roller := CritRoller.new(1.0, DartRandom.new(42))
	for _i: int in 100:
		assert_true(roller.roll())


func test_crit_roller_produces_deterministic_sequence_with_fixed_seed() -> void:
	var roller := CritRoller.new(0.05, DartRandom.new(1))
	var expected := [false, false, false, false, false, false, false, false, false, false]
	var actual := []
	for _i: int in 10:
		actual.append(roller.roll())
	assert_eq(actual, expected)


func test_crit_roller_observed_rate_is_within_003_007_over_10000_rolls() -> void:
	var roller := CritRoller.new(0.05, DartRandom.new(1))
	var hits := 0
	for _i: int in 10000:
		if roller.roll():
			hits += 1
	var rate := DartMath.quotient(hits, 10000)
	assert_true(rate >= 0.03)
	assert_true(rate <= 0.07)


func test_crit_roller_defaults_to_005_crit_chance_and_a_fresh_random() -> void:
	var roller := CritRoller.new()
	assert_eq(roller.crit_chance, 0.05)
	# Smoke test: roll() must not log an error.
	roller.roll()


## Not in the Dart file: the very crits Dart rolls with Random(1) in 200
## rolls (listed by a Dart script), and the die it was given.
func test_rolls_the_crits_of_dart() -> void:
	var dart_crits: Array[int] = [28, 73, 74, 98, 104, 111, 125, 146, 196]
	var random := DartRandom.new(1)
	var roller := CritRoller.new(0.05, random)
	assert_true(is_same(roller.random, random))
	var crits: Array[int] = []
	for roll: int in 200:
		if roller.roll():
			crits.append(roll)
	assert_eq(crits, dart_crits)

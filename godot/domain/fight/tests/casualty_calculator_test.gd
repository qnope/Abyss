extends TestCase
## test/domain/fight/casualty_calculator_test.dart: the fallen of a fight,
## wounded or dead.


func _c(key: String) -> Combatant:
	return Combatant.new(CombatSide.Value.PLAYER, key, 10, 1, 1)


func _many(n: int) -> Array[Combatant]:
	var fallen: Array[Combatant] = []
	for i: int in n:
		fallen.append(_c("u%d" % i))
	return fallen


func _keys(side: Array[Combatant]) -> Array:
	return side.map(func(c: Combatant) -> String: return c.type_key)


func test_wounded_probability_returns_08_at_pct_lost_0() -> void:
	assert_eq(CasualtyCalculator.wounded_probability(0.0), 0.8)


func test_wounded_probability_returns_08_at_pct_lost_05() -> void:
	assert_eq(CasualtyCalculator.wounded_probability(0.5), 0.8)


func test_wounded_probability_returns_about_05_at_midpoint_pct_lost_065() -> void:
	assert_almost_eq(CasualtyCalculator.wounded_probability(0.65), 0.5, 1e-9)


func test_wounded_probability_returns_02_at_pct_lost_08() -> void:
	assert_eq(CasualtyCalculator.wounded_probability(0.8), 0.2)


func test_wounded_probability_returns_02_at_pct_lost_1() -> void:
	assert_eq(CasualtyCalculator.wounded_probability(1.0), 0.2)


func test_partition_empty_input_produces_empty_wounded_and_dead_lists() -> void:
	var split := CasualtyCalculator.new(DartRandom.new(0)).partition([], 0.5)
	assert_true(split.wounded.is_empty())
	assert_true(split.dead.is_empty())


func test_partition_pct_lost_05_yields_wounded_count_between_70_and_90_of_100() -> void:
	var split := CasualtyCalculator.new(DartRandom.new(0)).partition(_many(100), 0.5)
	assert_eq(split.wounded.size() + split.dead.size(), 100)
	assert_true(split.wounded.size() >= 70 and split.wounded.size() <= 90)


func test_partition_pct_lost_09_yields_wounded_count_between_10_and_30_of_100() -> void:
	var split := CasualtyCalculator.new(DartRandom.new(0)).partition(_many(100), 0.9)
	assert_eq(split.wounded.size() + split.dead.size(), 100)
	assert_true(split.wounded.size() >= 10 and split.wounded.size() <= 30)


func test_partition_same_seed_and_inputs_yield_identical_partition() -> void:
	var a := CasualtyCalculator.new(DartRandom.new(123)).partition(_many(50), 0.6)
	var b := CasualtyCalculator.new(DartRandom.new(123)).partition(_many(50), 0.6)
	assert_eq(a.wounded.size(), b.wounded.size())
	assert_eq(a.dead.size(), b.dead.size())
	assert_eq(_keys(a.wounded), _keys(b.wounded))


func test_partition_evasive_scouts_fallen_scouts_always_come_back_wounded() -> void:
	var scouts: Array[Combatant] = []
	for _i: int in 50:
		scouts.append(_c("scout"))
	var split := CasualtyCalculator.new(DartRandom.new(5)).partition(scouts, 1)
	assert_true(split.dead.is_empty())
	assert_eq(split.wounded.size(), 50)


## Not in the Dart file: without a die, the calculator rolls one of its own.
func test_partitions_without_a_die_of_its_own() -> void:
	var split := CasualtyCalculator.new().partition(_many(10), 0.5)
	assert_eq(split.wounded.size() + split.dead.size(), 10)

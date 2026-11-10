extends TestCase
## test/domain/unit/unit_loss_calculator_test.dart: the units lost when the
## algae run short.

const SCOUT := UnitType.Value.SCOUT
const HARPOONIST := UnitType.Value.HARPOONIST
const GUARDIAN := UnitType.Value.GUARDIAN
const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL


func _losses(
	counts: Dictionary[UnitType.Value, int], production: int, stock: int
) -> Dictionary[UnitType.Value, int]:
	return UnitLossCalculator.calculate_losses(DomainSamples.units(counts), production, stock)


func test_calculate_losses_no_deficit_returns_empty_map() -> void:
	assert_eq(_losses({SCOUT: 10}, 100, 0), {})


func test_calculate_losses_exact_balance_returns_empty_map() -> void:
	# 10 scouts = 10 algae, 5 harpoonists = 10 algae => total 20
	assert_eq(_losses({SCOUT: 10, HARPOONIST: 5}, 15, 5), {})


func test_calculate_losses_proportional_losses_across_types() -> void:
	# 10 scouts (10 algae) + 10 guardians (30 algae) = 40 total
	# available = 20, deficit = 20, ratio = 0.5: each loses ceil(10 * 0.5) = 5
	assert_eq(_losses({SCOUT: 10, GUARDIAN: 10}, 20, 0), {SCOUT: 5, GUARDIAN: 5})


func test_calculate_losses_losses_rounded_up_ceil() -> void:
	# 3 scouts = 3 algae. available = 2, deficit = 1
	# ratio = 1/3 ≈ 0.333. ceil(3 * 0.333) = 1
	assert_eq(_losses({SCOUT: 3}, 2, 0), {SCOUT: 1})


func test_calculate_losses_losses_cannot_exceed_unit_count() -> void:
	# ratio = 1.0, available = 0
	assert_eq(_losses({SCOUT: 5, GUARDIAN: 3}, 0, 0), {SCOUT: 5, GUARDIAN: 3})


func test_calculate_losses_zero_count_units_not_in_result() -> void:
	var result := _losses({SCOUT: 10, HARPOONIST: 0}, 5, 0)
	assert_false(result.has(HARPOONIST))
	assert_eq(result, {SCOUT: 5})


func test_calculate_losses_single_unit_type() -> void:
	# 5 harpoonists = 10 algae. available = 8, deficit = 2
	# ratio = 2/10 = 0.2. ceil(5 * 0.2) = 1
	assert_eq(_losses({HARPOONIST: 5}, 8, 0), {HARPOONIST: 1})


func test_calculate_losses_stock_covers_deficit() -> void:
	# 5 scouts + 10 harpoonists = 5 + 20 = 25 algae, available=40
	assert_eq(_losses({SCOUT: 5, HARPOONIST: 10}, 10, 30), {})


func test_calculate_losses_stock_not_enough() -> void:
	# 10 scouts + 5 harpoonists = 20 algae, available=15, ratio = 0.25
	# scouts: ceil(10 * 0.25) = 3, harpoonists: ceil(5 * 0.25) = 2
	assert_eq(_losses({SCOUT: 10, HARPOONIST: 5}, 10, 5), {SCOUT: 3, HARPOONIST: 2})


func test_calculate_losses_100_percent_deficit_kills_all_units() -> void:
	assert_eq(
		_losses({SCOUT: 3, GUARDIAN: 2, ADMIRAL: 4}, 0, 0), {SCOUT: 3, GUARDIAN: 2, ADMIRAL: 4}
	)


## Not in the Dart file: the losses follow the order of the units, and more
## algae owed than eaten still loses no more than every unit.
func test_calculate_losses_keeps_the_order_of_the_units() -> void:
	assert_eq(_losses({GUARDIAN: 3, SCOUT: 5}, 0, 0).keys(), [GUARDIAN, SCOUT])
	assert_eq(_losses({SCOUT: 5}, -10, 0), {SCOUT: 5})


func test_calculate_losses_all_levels_no_deficit_returns_empty() -> void:
	var result := UnitLossCalculator.calculate_losses_all_levels(
		{1: DomainSamples.units({SCOUT: 5})}, 100, 0
	)
	assert_eq(result, {})


func test_calculate_losses_all_levels_counts_units_on_all_levels_for_consumption() -> void:
	# Lv1: 10 scouts=10, Lv2: 10 scouts=10 => total 20, available=10,
	# ratio=0.5: each level loses ceil(10*0.5)=5, aggregated: scout=10
	var result := UnitLossCalculator.calculate_losses_all_levels(
		{1: DomainSamples.units({SCOUT: 10}), 2: DomainSamples.units({SCOUT: 10})}, 10, 0
	)
	assert_eq(result, {SCOUT: 10})


func test_calculate_losses_all_levels_does_not_mutate_units() -> void:
	var lv1 := DomainSamples.units({SCOUT: 10})
	var lv2 := DomainSamples.units({SCOUT: 10})
	UnitLossCalculator.calculate_losses_all_levels({1: lv1, 2: lv2}, 0, 0)
	assert_eq(lv1[SCOUT].count, 10)
	assert_eq(lv2[SCOUT].count, 10)


func test_apply_losses_all_levels_no_deficit_does_nothing() -> void:
	var lv1 := DomainSamples.units({SCOUT: 5})
	var result := UnitLossCalculator.apply_losses_all_levels({1: lv1}, 100, 0)
	assert_eq(result, {})
	assert_eq(lv1[SCOUT].count, 5)


func test_apply_losses_all_levels_mutates_units_on_all_levels() -> void:
	# Lv1: 10 scouts=10, Lv2: 10 scouts=10 => total 20, available=10, ratio=0.5
	var lv1 := DomainSamples.units({SCOUT: 10})
	var lv2 := DomainSamples.units({SCOUT: 10})
	UnitLossCalculator.apply_losses_all_levels({1: lv1, 2: lv2}, 10, 0)
	assert_eq(lv1[SCOUT].count, 5)
	assert_eq(lv2[SCOUT].count, 5)


func test_apply_losses_all_levels_returns_aggregated_losses() -> void:
	var lv1 := DomainSamples.units({SCOUT: 6})
	var lv2 := DomainSamples.units({SCOUT: 4})
	# total consumption = 10, available = 0, ratio = 1.0
	var result := UnitLossCalculator.apply_losses_all_levels({1: lv1, 2: lv2}, 0, 0)
	assert_eq(result, {SCOUT: 10})
	assert_eq(lv1[SCOUT].count, 0)
	assert_eq(lv2[SCOUT].count, 0)

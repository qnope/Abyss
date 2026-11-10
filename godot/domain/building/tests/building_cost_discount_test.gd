extends TestCase
## test/domain/building/building_cost_discount_test.dart: the discount of
## Chantiers économes on every upgrade.

const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const HQ := BuildingType.Value.HEADQUARTERS

var _thrifty := BuildingCostCalculator.new(15)


func _check(calculator: BuildingCostCalculator) -> UpgradeCheck:
	return calculator.check_upgrade(HQ, 0, DomainSamples.resources({CORAL: 51, ORE: 34}), {})


func test_chantiers_economes_discount_no_discount_by_default() -> void:
	assert_eq(BuildingCostCalculator.new().upgrade_cost(HQ, 0), {CORAL: 60, ORE: 40})


func test_chantiers_economes_discount_takes_15_percent_off_every_resource_rounded_down() -> void:
	assert_eq(_thrifty.upgrade_cost(HQ, 0), {CORAL: 51, ORE: 34})
	# 629 * 0.85 = 534.65 ; 419 * 0.85 = 356.15
	assert_eq(_thrifty.upgrade_cost(HQ, 5), {CORAL: 534, ORE: 356})


func test_chantiers_economes_discount_a_maxed_building_stays_without_cost() -> void:
	assert_eq(_thrifty.upgrade_cost(HQ, 10), {})


func test_chantiers_economes_discount_the_check_accepts_the_discounted_price() -> void:
	assert_true(_check(_thrifty).can_upgrade)
	assert_eq(_check(BuildingCostCalculator.new()).missing_resources, {CORAL: 9, ORE: 6})


func test_chantiers_economes_discount_an_upgrade_by_a_player_with_the_option_pays_less() -> void:
	var options: Array[TechOption.Value] = [TechOption.Value.A, TechOption.Value.B]
	var player := Player.new(
		"Test", "p", 0, 0, DomainSamples.resources({CORAL: 100, ORE: 100}), DomainSamples.buildings({HQ: 0}),
		TechHelpers.tech_branches_with([TechHelpers.researched_branch(TechBranch.Value.RESOURCES, 4, options)]),
	)
	var result := UpgradeBuildingAction.new(HQ).execute(GameSamples.game([player]), player)
	assert_true(result.is_success)
	assert_eq(player.resources[CORAL].amount, 49)
	assert_eq(player.resources[ORE].amount, 66)

extends TestCase
## test/domain/building/upgrade_readiness_test.dart: whether a building can
## go up a level right now. The Dart test takes the buildings, the stocks
## and the worksite of a new Player, which goes with the game module: the
## same maps are built here.

const HQ := BuildingType.Value.HEADQUARTERS
const FARM := BuildingType.Value.ALGAE_FARM
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE

## A player whose headquarters stands at level 2, rich enough to pay.
var _buildings := VectorInputs.buildings({"headquarters": 2, "algaeFarm": 1})
var _resources := VectorInputs.resources(
	{"algae": 5000, "coral": 5000, "ore": 5000, "energy": 5000, "pearl": 5}
)
var _worksite := Worksite.new()


func _readiness_of(
	type: BuildingType.Value, captured: Dictionary[TransitionBaseType.Value, bool] = {}
) -> UpgradeReadiness:
	return UpgradeReadiness.of(type, _buildings, _resources, _worksite, captured)


func test_a_free_worksite_the_costs_paid_and_the_prerequisites_met_ready() -> void:
	var readiness := _readiness_of(FARM)
	assert_true(readiness.site_free)
	assert_true(readiness.is_ready())
	assert_false(readiness.is_locked())


func test_no_worksite_left_this_turn_not_ready_though_not_locked() -> void:
	_worksite.upgrades = 1
	var readiness := _readiness_of(FARM)
	assert_false(readiness.site_free)
	assert_true(readiness.check.can_upgrade)
	assert_false(readiness.is_ready())
	assert_false(readiness.is_locked())


func test_too_poor_to_pay_not_ready_though_not_locked() -> void:
	_resources[CORAL].amount = 0
	var readiness := _readiness_of(FARM)
	assert_false(readiness.is_ready())
	assert_false(readiness.is_locked())


func test_a_prerequisite_missing_not_ready_and_locked() -> void:
	_buildings[FARM].level = 2
	var readiness := _readiness_of(FARM)
	assert_eq(readiness.check.missing_prerequisites, {HQ: 4})
	assert_false(readiness.is_ready())
	assert_true(readiness.is_locked())


func test_a_base_to_capture_first_locks_the_building() -> void:
	_buildings[HQ].level = 5
	var module := BuildingType.Value.DESCENT_MODULE
	var locked := _readiness_of(module)
	assert_true(locked.is_locked())
	assert_eq(locked.check.missing_captured_base, TransitionBaseType.Value.FAILLE)
	var captured := _readiness_of(module, {TransitionBaseType.Value.FAILLE: true})
	assert_false(captured.is_locked())
	assert_true(captured.is_ready())
	assert_null(captured.check.missing_captured_base)


func test_the_volcanic_core_to_capture_first_locks_the_kernel() -> void:
	_buildings[HQ].level = 10
	var kernel := _readiness_of(BuildingType.Value.VOLCANIC_KERNEL)
	assert_eq(kernel.check.missing_prerequisites, {})
	assert_true(kernel.is_locked())


func test_at_its_maximum_level_neither_ready_nor_locked() -> void:
	_buildings[FARM].level = 5
	var readiness := _readiness_of(FARM)
	assert_true(readiness.check.is_max_level)
	assert_false(readiness.is_ready())
	assert_false(readiness.is_locked())


func test_a_discount_lowers_the_costs_it_checks() -> void:
	_buildings[HQ].level = 0
	_resources[CORAL].amount = 50
	_resources[ORE].amount = 40
	var with_discount := func(percent: int) -> UpgradeReadiness:
		return UpgradeReadiness.of(HQ, _buildings, _resources, _worksite, {}, false, percent)
	var full: UpgradeReadiness = with_discount.call(0)
	var discounted: UpgradeReadiness = with_discount.call(20)
	assert_false(full.is_ready())
	assert_true(discounted.is_ready())

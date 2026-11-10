extends TestCase
## What a check of an upgrade holds. Dart has no test of its own for
## upgrade_check.dart: its const constructor defaults to empty const maps.


func test_misses_nothing_unless_told() -> void:
	var check := UpgradeCheck.new(true)
	assert_true(check.can_upgrade)
	assert_false(check.is_max_level)
	assert_eq(check.missing_resources, {})
	assert_eq(check.missing_prerequisites, {})
	assert_null(check.missing_captured_base)
	assert_false(check.missing_captured_kernel)


func test_two_checks_share_no_map() -> void:
	var first := UpgradeCheck.new(false)
	first.missing_resources[ResourceType.Value.ORE] = 3
	first.missing_prerequisites[BuildingType.Value.HEADQUARTERS] = 2
	var second := UpgradeCheck.new(false)
	assert_eq(second.missing_resources, {})
	assert_eq(second.missing_prerequisites, {})

extends TestCase
## test/domain/raid/raid_spoils_cap_test.dart: the loot of a repelled raid,
## capped by the production of the base.

const ALGAE := ResourceType.Value.ALGAE
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const PEARL := ResourceType.Value.PEARL


func test_loot_is_capped_at_two_turns_of_production_pearls_aside() -> void:
	var capped := RaidSpoils.cap_to_production(
		{ALGAE: 400, CORAL: 40, ORE: 300, PEARL: 2}, {ALGAE: 50, CORAL: 30}
	)
	assert_eq(capped, {ALGAE: 100, CORAL: 40, ORE: 0, PEARL: 2})
	assert_eq(capped.keys(), [ALGAE, CORAL, ORE, PEARL])

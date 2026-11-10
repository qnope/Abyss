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


func test_a_repelled_raid_brings_no_more_than_two_turns_of_production() -> void:
	var player := RaidSamples.raid_player({UnitType.Value.HARPOONIST: 30}, 0, 1)
	var wave := MonsterLair.new(MonsterDifficulty.Value.EASY, 5)
	var report := RaidBattle.fight(player, wave, 10, DartRandom.new(1))
	var produced := ProductionCalculator.from_buildings(player.buildings)
	assert_true(report.victory)
	assert_eq(report.loot[CORAL], 2 * produced[CORAL])
	assert_eq(report.loot[ORE], 2 * produced[ORE])

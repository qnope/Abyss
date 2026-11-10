extends TestCase
## test/domain/tech/tech_effects_economy_test.dart: what the Resources and
## the Explorer branches change in the rules.

const RESOURCES := TechBranch.Value.RESOURCES
const EXPLORER := TechBranch.Value.EXPLORER
const A := TechOption.Value.A
const B := TechOption.Value.B
const ALGAE := ResourceType.Value.ALGAE
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY
const PEARL := ResourceType.Value.PEARL


func _effects(
	branch: TechBranch.Value, level: int, options: Array[TechOption.Value]
) -> TechEffects:
	return TechHelpers.effects_of([TechHelpers.researched_branch(branch, level, options)])


func test_tech_effects_resources_defaults_without_research() -> void:
	var tech := TechHelpers.effects_of([])
	for type: ResourceType.Value in ResourceType.Value.values():
		assert_eq(tech.production_percent(type), 0)
	assert_eq(tech.pillage_rate(), 0.3)
	assert_eq(tech.upgrade_discount_percent(), 0)


func test_tech_effects_resources_each_tier_gives_plus_20_percent_on_every_resource() -> void:
	var tech := _effects(RESOURCES, 3, [A])
	assert_eq(tech.production_percent(ORE), 40)
	assert_eq(tech.production_percent(PEARL), 40)


func test_tech_effects_resources_culture_intensive_adds_plus_35_percent_algae_and_coral() -> void:
	var tech := _effects(RESOURCES, 2, [A])
	assert_eq(tech.production_percent(ALGAE), 55)
	assert_eq(tech.production_percent(CORAL), 55)
	assert_eq(tech.production_percent(ORE), 20)
	assert_eq(tech.production_percent(ENERGY), 20)


func test_tech_effects_resources_forage_profond_adds_plus_35_percent_ore_and_energy() -> void:
	var tech := _effects(RESOURCES, 2, [B])
	assert_eq(tech.production_percent(ORE), 55)
	assert_eq(tech.production_percent(ENERGY), 55)
	assert_eq(tech.production_percent(ALGAE), 20)


func test_tech_effects_resources_coffres_scelles_halves_the_pillage_rate() -> void:
	var tech := _effects(RESOURCES, 4, [A, A])
	assert_eq(tech.pillage_rate(), 0.15)
	assert_eq(tech.upgrade_discount_percent(), 0)


func test_tech_effects_resources_chantiers_economes_discounts_upgrades_by_15_percent() -> void:
	var tech := _effects(RESOURCES, 4, [A, B])
	assert_eq(tech.upgrade_discount_percent(), 15)
	assert_eq(tech.pillage_rate(), 0.3)


func test_tech_effects_explorer_defaults_without_research() -> void:
	var tech := TechHelpers.effects_of([])
	assert_eq(tech.reveal_side(), 3)
	assert_eq(tech.muffle(4), 4)
	assert_eq(tech.loot_percent(), 100)
	assert_eq(tech.raid_warning_turns(), 2)


func test_tech_effects_explorer_each_tier_widens_the_revealed_square_by_2() -> void:
	assert_eq(_effects(EXPLORER, 5, [B, B]).reveal_side(), 9)


func test_tech_effects_explorer_sonar_profond_widens_it_by_2_more() -> void:
	assert_eq(_effects(EXPLORER, 2, [A]).reveal_side(), 7)


func test_tech_effects_explorer_nage_silencieuse_muffles_every_noise() -> void:
	var tech := _effects(EXPLORER, 2, [B])
	assert_eq(tech.muffle(4), 0)
	assert_eq(tech.reveal_side(), 5)


func test_tech_effects_explorer_pillards_d_epaves_gives_plus_50_percent_loot() -> void:
	var tech := _effects(EXPLORER, 4, [A, A])
	assert_eq(tech.loot_percent(), 150)
	assert_eq(tech.boost_loot({ORE: 10, PEARL: 3}), {ORE: 15, PEARL: 4})


func test_tech_effects_explorer_sentinelles_announce_raids_4_turns_ahead() -> void:
	var tech := _effects(EXPLORER, 4, [A, B])
	assert_eq(tech.raid_warning_turns(), 4)
	assert_eq(tech.loot_percent(), 100)

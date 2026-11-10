extends TestCase
## test/domain/raid/raid_tech_perks_test.dart, groups 'Coffres scellés' and
## "Pillards d'épaves": the research that changes a raid's spoils. Its
## group 'Sentinelles' is raid_tech_perks_sentinelles_test.gd.

const A := TechOption.Value.A
const B := TechOption.Value.B
const CORAL := ResourceType.Value.CORAL

var _wave := MonsterLair.new(MonsterDifficulty.Value.EASY, 5)


## `_with`: `player` with its `branch` researched to level 4 with `options`.
static func with_research(
	player: Player, branch: TechBranch.Value, options: Array[TechOption.Value]
) -> Player:
	player.tech_branches[branch] = TechHelpers.researched_branch(branch, 4, options)
	return player


func test_coffres_scelles_a_lost_raid_pillages_15_percent_instead_of_30() -> void:
	var player := with_research(RaidSamples.raid_player(), TechBranch.Value.RESOURCES, [A, A])
	var report := RaidBattle.fight(player, _wave, 10, DartRandom.new(1))

	assert_false(report.victory)
	assert_eq(report.pillaged[CORAL], 150)
	assert_eq(player.resources[CORAL].amount, 850)
	assert_false(report.pillaged.has(ResourceType.Value.PEARL))


func test_coffres_scelles_chantiers_economes_leaves_the_pillage_at_30_percent() -> void:
	var player := with_research(RaidSamples.raid_player(), TechBranch.Value.RESOURCES, [A, B])
	var report := RaidBattle.fight(player, _wave, 10, DartRandom.new(1))

	assert_eq(report.pillaged[CORAL], 300)


func test_coffres_scelles_raid_spoils_pillage_takes_the_rate_it_is_given() -> void:
	var player := RaidSamples.raid_player()
	var taken := RaidSpoils.pillage(player.resources, 0.15)
	assert_eq(taken[ResourceType.Value.ORE], 150)
	assert_eq(player.resources[ResourceType.Value.ORE].amount, 850)


func test_pillards_d_epaves_a_repelled_raid_yields_50_percent_more_loot() -> void:
	var plain := RaidBattle.fight(_garrison(), _wave, 10, DartRandom.new(1)).loot
	var raider_player := with_research(_garrison(), TechBranch.Value.EXPLORER, [A, A])
	var raider := RaidBattle.fight(raider_player, _wave, 10, DartRandom.new(1)).loot

	assert_true(plain[CORAL] > 0)
	for type: ResourceType.Value in plain:
		assert_eq(raider[type], DartMath.trunc_div(plain[type] * 150, 100))


func _garrison() -> Player:
	return RaidSamples.raid_player({UnitType.Value.HARPOONIST: 30}, 0, 1)

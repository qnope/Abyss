extends TestCase
## The bases and kernels the tests of the raids and of the volcano share.

const HARPOONIST := UnitType.Value.HARPOONIST
const SCOUT := UnitType.Value.SCOUT


func test_a_raid_player_holds_1000_of_everything_and_the_units_given() -> void:
	var player := RaidSamples.raid_player({HARPOONIST: 4, SCOUT: 2}, 3, 2)
	assert_eq([player.id, player.name], ["p1", "Test"])
	for stock: GameResource in player.resources.values():
		assert_eq([stock.amount, stock.max_storage], [1000, 100000])
	assert_eq(player.resources.keys(), ResourceType.Value.values())
	assert_eq(Building.level_in(player.buildings, BuildingType.Value.CORAL_CITADEL), 3)
	assert_eq(Building.level_in(player.buildings, BuildingType.Value.HEADQUARTERS), 2)
	assert_eq(player.buildings.size(), 11)
	assert_eq(player.unit_counts_on_level(1), {SCOUT: 2, HARPOONIST: 4})
	assert_eq(RaidSamples.units_on_base(player), 6)


func test_a_bare_raid_player_has_no_unit_and_buildings_at_level_0() -> void:
	var player := RaidSamples.raid_player()
	assert_eq(RaidSamples.units_on_base(player), 0)
	assert_eq(Building.level_in(player.buildings, BuildingType.Value.CORAL_CITADEL), 0)

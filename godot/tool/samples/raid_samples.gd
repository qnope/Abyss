class_name RaidSamples
extends RefCounted
## The bases and kernels the tests of the raids and of the volcano strike:
## the twins of test/domain/raid/raid_test_helper.dart, test/domain/volcano/
## volcano_test_helper.dart and test/helpers/kernel_garrison_helpers.dart.


## `raidPlayer`: player "p1" named "Test" with 1000 of every resource (under
## a storage of 100000), `units` on the base level, a Coral Citadel at
## `citadel_level` and a headquarters at `headquarters_level`, whose income
## caps the loot of a raid.
static func raid_player(
	units: Dictionary[UnitType.Value, int] = {}, citadel_level := 0, headquarters_level := 0
) -> Player:
	var resources: Dictionary[ResourceType.Value, GameResource] = {}
	for type: ResourceType.Value in ResourceType.Value.values():
		resources[type] = GameResource.new(type, 1000, 100000)
	var player := Player.new("Test", "p1", 0, 0, resources)
	var citadel := BuildingType.Value.CORAL_CITADEL
	var headquarters := BuildingType.Value.HEADQUARTERS
	player.buildings[citadel] = Building.new(citadel, citadel_level)
	player.buildings[headquarters] = Building.new(headquarters, headquarters_level)
	for type: UnitType.Value in units:
		player.units_on_level(1)[type].count = units[type]
	return player


## `unitsOnBase`: every unit on the base level.
static func units_on_base(player: Player) -> int:
	var total := 0
	for unit: Unit in player.units_on_level(1).values():
		total += unit.count
	return total

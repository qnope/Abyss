class_name KernelGarrison
extends RefCounted
## lib/domain/volcano/kernel_garrison.dart: the units shut inside the
## volcanic kernel to guard it.
##
## They live in their own stock of `Player.units_per_level`, under
## STOCK_KEY, so they eat algae like any unit but neither explore nor fight
## anywhere else. Only they defend the kernel against the waves.

## Map level of the volcanic kernel.
const VOLCANO_LEVEL := 3
## Key of the garrison's stock in `Player.units_per_level`: the heart of the
## volcano, one step below its map.
const STOCK_KEY := 4


## Units of the garrison, by type, empty ones left out.
static func of(player: Player) -> Dictionary[UnitType.Value, int]:
	return player.unit_counts_on_level(STOCK_KEY)


## Number of units in the garrison.
static func size_of(player: Player) -> int:
	var total := 0
	for count: int in of(player).values():
		total += count
	return total


## The garrison's stock, created with every unit type when missing.
static func stock_of(player: Player) -> Dictionary[UnitType.Value, Unit]:
	return stock_at(player, STOCK_KEY)


## `player`'s stock under `key`, created with every unit type when missing:
## the types it lacks go after those it holds, in the order of UnitType.
static func stock_at(player: Player, key: int) -> Dictionary[UnitType.Value, Unit]:
	if not player.units_per_level.has(key):
		var created: Dictionary[UnitType.Value, Unit] = {}
		player.units_per_level[key] = created
	var stock: Dictionary[UnitType.Value, Unit] = player.units_per_level[key]
	for type: UnitType.Value in UnitType.Value.values():
		if not stock.has(type):
			stock[type] = Unit.new(type)
	return stock


## Level of `player`'s volcanic kernel building.
static func kernel_level_of(player: Player) -> int:
	return Building.level_in(player.buildings, BuildingType.Value.VOLCANIC_KERNEL)

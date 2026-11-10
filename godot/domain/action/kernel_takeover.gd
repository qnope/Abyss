class_name KernelTakeover
extends RefCounted
## lib/domain/action/kernel_takeover.dart: what a won attack does to a held
## kernel: it loses one level and, when it reaches level 0, the attacker
## holds it and the garrison of the old owner is lost with it. The owner
## keeps the turn of its loss, which holds back the kraken wave of that
## turn.


## Takes `owner`'s kernel at (`x`, `y`) of the volcano level of `game` down
## to `after`; returns the units of the garrison the owner lost.
static func apply(
	game: Game, x: int, y: int, attacker: Player, owner: Player, after: int
) -> Dictionary[UnitType.Value, int]:
	owner.raid_state.kernel_siege_lost_turn = game.turn
	owner.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = after
	if after > 0:
		return {}
	var lost := KernelGarrison.of(owner)
	for unit: Unit in KernelGarrison.stock_of(owner).values():
		unit.count = 0
	var map: GameMap = game.levels[KernelGarrison.VOLCANO_LEVEL]
	map.set_cell(x, y, map.cell_at(x, y).copy_with({"collected_by": attacker.id}))
	return lost

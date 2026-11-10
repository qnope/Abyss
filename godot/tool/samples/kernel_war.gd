class_name KernelWar
extends RefCounted
## The GDScript twin of `KernelWar` of test/helpers/kernel_war_helper.dart:
## a game against two factions at turn 12, tutorial over, where `owner()`
## holds the volcanic kernel at `kernel_level` and `attacker()` stands ready
## on the volcano level. With `human_holds`, the human is the owner;
## `personalities` pins the two factions.

## `horde`: an army that takes the kernel.
const HORDE: Dictionary[UnitType.Value, int] = {UnitType.Value.HARPOONIST: 80}
## `smallGarrison`.
const SMALL_GARRISON: Dictionary[UnitType.Value, int] = {UnitType.Value.HARPOONIST: 3}
## `fortress`: a garrison nobody beats.
const FORTRESS: Dictionary[UnitType.Value, int] = {UnitType.Value.GUARDIAN: 120, UnitType.Value.HARPOONIST: 120}

var game: Game
var at: GridPosition
var human_holds: bool


## `KernelWar(kernelLevel:, mapSeed:, humanHolds:, personalities:)`, the
## kernel the first cell of the volcano level found row by row.
func _init(kernel_level := 3, map_seed := 7, human_holds_ := false, personalities: Variant = null) -> void:
	game = GameFactory.new_game("Nemo", map_seed, Difficulty.Value.NORMAL, false, 2, personalities)
	game.turn = 12
	human_holds = human_holds_
	var map := _map()
	for y: int in map.height:
		for x: int in map.width:
			if map.cell_at(x, y).content == CellContentType.Value.VOLCANIC_KERNEL and at == null:
				at = GridPosition.new(x, y)
	_set_up(kernel_level)


func attacker() -> Player:
	return game.players[game.factions()[0].id()]


func owner() -> Player:
	return game.human_player() if human_holds else game.players[game.factions()[1].id()]


func human() -> Player:
	return game.human_player()


## The id of the player who holds the kernel (a String), or null.
func holder() -> Variant:
	return _map().cell_at(at.x, at.y).collected_by


func kernel_of(p: Player) -> int:
	return KernelGarrison.kernel_level_of(p)


func put(player: Player, level: int, units: Dictionary[UnitType.Value, int]) -> void:
	for type: UnitType.Value in units:
		KernelGarrison.stock_at(player, level)[type].count = units[type]


func count(player: Player, level: int, type: UnitType.Value) -> int:
	return KernelGarrison.stock_at(player, level)[type].count


## Puts `army` on the volcano level of the attacker.
func arm(army: Dictionary[UnitType.Value, int] = HORDE) -> void:
	put(attacker(), KernelGarrison.VOLCANO_LEVEL, army)


## Puts `units` in the garrison of the owner.
func garrison(units: Dictionary[UnitType.Value, int]) -> void:
	put(owner(), KernelGarrison.STOCK_KEY, units)


func _map() -> GameMap:
	return game.levels[KernelGarrison.VOLCANO_LEVEL]


func _set_up(kernel_level: int) -> void:
	ObjectiveMigration.state_of(game, human()).tutorial_enabled = false
	var map := _map()
	map.set_cell(at.x, at.y, map.cell_at(at.x, at.y).copy_with({"collected_by": owner().id}))
	owner().buildings[BuildingType.Value.VOLCANIC_KERNEL] = Building.new(
		BuildingType.Value.VOLCANIC_KERNEL, kernel_level
	)
	for p: Player in [attacker(), owner(), human()]:
		p.add_revealed_cell(KernelGarrison.VOLCANO_LEVEL, at)
		for l: int in [1, 2, 3, KernelGarrison.STOCK_KEY]:
			for unit: Unit in KernelGarrison.stock_at(p, l).values():
				unit.count = 0

class_name DeepScouts
extends RefCounted
## The GDScript twin of test/helpers/deep_scout_helper.dart: a game against
## `factions` factions (6 give 32-cell maps) where the first faction scouts;
## it holds nothing yet and has no scout anywhere.

var game: Game


func _init(factions := 6, map_seed := 7) -> void:
	game = GameFactory.new_game("Nemo", map_seed, Difficulty.Value.NORMAL, false, factions)
	put(1, 0)


func faction() -> Player:
	return game.players[game.factions()[0].id()]


## `turn()`: the `FactionTurn` of the faction, its seeds `Random(3)`.
func turn() -> ScriptTurn:
	return FactionTurn.new(game, faction(), ActionExecutor.new(), DartRandom.new(3, false))


## Puts `n` scouts on `level` of the faction.
func put(level: int, n: int) -> void:
	KernelGarrison.stock_at(faction(), level)[UnitType.Value.SCOUT].count = n


## Scouts of the faction on `level`; a level it never reached has none.
func scouts(level: int) -> int:
	var units: Dictionary = faction().units_per_level.get(level, {})
	var scout: Unit = units.get(UnitType.Value.SCOUT)
	return 0 if scout == null else scout.count


## Gives the faction the first post of `kind` and its passage building; a
## Cheminée means it already stands on level 2, so a descent there keeps
## its fog.
func hold(kind: TransitionBaseType.Value) -> void:
	var level := 1 if kind == TransitionBaseType.Value.FAILLE else 2
	put(level, scouts(level))
	var at := cells(level, func(c: MapCell) -> bool:
		return c.transition_base != null and c.transition_base.type == kind)[0]
	game.levels[level].cell_at(at.x, at.y).transition_base.captured_by = faction().id
	faction().add_revealed_cell(level, at)
	var passage := (
		BuildingType.Value.DESCENT_MODULE if kind == TransitionBaseType.Value.FAILLE
		else BuildingType.Value.PRESSURE_CAPSULE
	)
	faction().buildings[passage] = Building.new(passage, 1)


## Cells of `level` whose content passes `test`, row by row.
func cells(level: int, test: Callable) -> Array[GridPosition]:
	var map: GameMap = game.levels[level]
	var found: Array[GridPosition] = []
	for y: int in map.height:
		for x: int in map.width:
			if test.call(map.cell_at(x, y)):
				found.append(GridPosition.new(x, y))
	return found


## The cells of the volcanic kernel on level 3.
func kernel() -> Array[GridPosition]:
	return cells(3, func(c: MapCell) -> bool: return c.content == CellContentType.Value.VOLCANIC_KERNEL)


## Reveals the `side` x `side` square around `p` on `level`.
func reveal(level: int, p: GridPosition, side := 3) -> void:
	var map: GameMap = game.levels[level]
	for c: GridPosition in RevealAreaCalculator.cells_to_reveal(p.x, p.y, side, map.width, map.height):
		faction().add_revealed_cell(level, c)


## Targets of the faction's pending explorations on `level`.
func targets(level: int) -> Array[GridPosition]:
	var found: Array[GridPosition] = []
	for o: ExplorationOrder in faction().pending_explorations:
		if o.level == level:
			found.append(o.target)
	return found


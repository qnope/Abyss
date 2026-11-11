class_name MoveSamples
extends RefCounted
## Sample games for the actions that move units from one level to another:
## a descent, reinforcements and the kernel's garrison, as the helpers of
## test/domain/action/ and test/domain/volcano/ build them.


## `createDescendScenario`: a 10x10 plain map (seed 42) with a Faille on
## (5, 5) that `captured_by` holds, and the player "test" with
## `scouts` scouts, its descent module at `module_level` and no capsule.
static func descend_game(
	captured_by: Variant = "test", module_level := 1, scouts := 10,
	content := CellContentType.Value.TRANSITION_BASE,
) -> Game:
	var cells := MapSamples.plain_cells(100)
	if content == CellContentType.Value.TRANSITION_BASE:
		var faille := TransitionBase.new(TransitionBaseType.Value.FAILLE, "Faille", captured_by)
		cells[55] = MapCell.new(TerrainType.Value.PLAIN, content, null, null, faille)
	var buildings := DomainSamples.buildings({
		BuildingType.Value.DESCENT_MODULE: module_level, BuildingType.Value.PRESSURE_CAPSULE: 0
	})
	var units: Dictionary[int, Dictionary] = {1: ActionSamples.scouts_only(scouts)}
	var player := Player.new("Test", "test", 0, 0, null, buildings, null, units)
	var levels: Dictionary[int, GameMap] = {1: GameMap.new(10, 10, cells, 42)}
	return Game.new(player.id, {player.id: player}, 1, null, levels)


## `buildReinforcementMap`: a 5x5 plain map (seed 1), its centre holding
## `base` when given.
static func reinforcement_map(base: TransitionBase = null) -> GameMap:
	var map := MapSamples.plain_map(5, 5, 1)
	if base != null:
		map.cells[12] = MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.TRANSITION_BASE, null, null, base)
	return map


## `createReinforcementScenario`: the player "p1" with `scouts` scouts on
## level 1 and the Faille Alpha that `captured_by` holds at its centre,
## level 2 generated unless `with_target_level` is false.
static func reinforcement_game(scouts := 5, captured_by := "p1", with_target_level := true) -> Game:
	var base := TransitionBase.new(TransitionBaseType.Value.FAILLE, "Faille Alpha", captured_by)
	var units: Dictionary[int, Dictionary] = {1: ActionSamples.scouts_only(scouts)}
	var player := Player.new("Test", "p1", 0, 0, null, null, null, units)
	var levels: Dictionary[int, GameMap] = {1: reinforcement_map(base)}
	if with_target_level:
		levels[2] = reinforcement_map()
	return Game.new(player.id, {player.id: player}, 1, null, levels)


## `volcanoGame`: the game of `player` whose 1x1 level 3 holds the kernel,
## captured by `player` unless `captured` is false.
static func volcano_game(player: Player, captured := true) -> Game:
	var cell := MapCell.new(
		TerrainType.Value.PLAIN, CellContentType.Value.VOLCANIC_KERNEL, null, player.id if captured else null
	)
	var levels: Dictionary[int, GameMap] = {3: GameMap.new(1, 1, [cell], 0)}
	return Game.new(player.id, {player.id: player}, 1, null, levels)

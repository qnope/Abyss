class_name SiegeSamples
extends RefCounted
## The games of the assaults led by an Abyss Admiral on what nobody holds
## yet, as test/domain/action/attack_transition_base_helper.dart and
## attack_volcanic_kernel_helper.dart build them: a 5x5 plain map (seed 42)
## holding the target on (1, 1), and the player "test-uuid" alone, every
## building at 0 but those given, `stock` on `level`. The player is the
## game's human.


## `createAttackScenario`: a post of `base_type` that `captured_by` holds
## (null for nobody), or a cell of `content` with that post when
## `with_transition_base`; the descent module and the capsule at the levels
## given.
static func attack_game(
	stock: Dictionary[UnitType.Value, int] = {},
	base_type := TransitionBaseType.Value.FAILLE,
	captured_by: Variant = null,
	descent_module_level := 1,
	pressure_capsule_level := 0,
	content := CellContentType.Value.TRANSITION_BASE,
	with_transition_base := true,
	level := 1,
) -> Game:
	var cells := MapSamples.plain_cells(25)
	if with_transition_base:
		var name := "Faille" if base_type == TransitionBaseType.Value.FAILLE else "Cheminée"
		var base := TransitionBase.new(base_type, name, captured_by)
		cells[6] = MapCell.new(TerrainType.Value.PLAIN, content, null, null, base)
	var levels := {
		BuildingType.Value.DESCENT_MODULE: descent_module_level,
		BuildingType.Value.PRESSURE_CAPSULE: pressure_capsule_level,
	}
	return _game(cells, stock, level, levels)


## `createKernelScenario`: a cell of `content`, the volcanic kernel by
## default, that `collected_by` holds (null for nobody).
static func kernel_game(
	stock: Dictionary[UnitType.Value, int] = {},
	collected_by: Variant = null,
	content := CellContentType.Value.VOLCANIC_KERNEL,
	level := 3,
) -> Game:
	var cells := MapSamples.plain_cells(25)
	cells[6] = MapCell.new(TerrainType.Value.PLAIN, content, null, collected_by)
	return _game(cells, stock, level, {})


static func _game(
	cells: Array[MapCell], stock: Dictionary[UnitType.Value, int], level: int, given: Dictionary
) -> Game:
	var buildings: Dictionary[BuildingType.Value, Building] = {}
	for type: BuildingType.Value in BuildingType.Value.values():
		var at: int = given.get(type, 0)
		buildings[type] = Building.new(type, at)
	var units: Dictionary[UnitType.Value, Unit] = {}
	for type: UnitType.Value in UnitType.Value.values():
		var count: int = stock.get(type, 0)
		units[type] = Unit.new(type, count)
	var per_level: Dictionary[int, Dictionary] = {level: units}
	var player := Player.new("Test", "test-uuid", 0, 0, null, buildings, null, per_level)
	var maps: Dictionary[int, GameMap] = {level: GameMap.new(5, 5, cells, 42)}
	return Game.new(player.id, {player.id: player}, 1, null, maps)

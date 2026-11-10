class_name Player
extends RefCounted
## lib/domain/game/player.dart: a player of a game, the human or a faction,
## and everything it holds.

var name: String
var id: String
var base_x: int
var base_y: int
var resources: Dictionary[ResourceType.Value, GameResource]
var buildings: Dictionary[BuildingType.Value, Building]
var tech_branches: Dictionary[TechBranch.Value, TechBranchState]
## Each value a `Dictionary[UnitType.Value, Unit]`.
var units_per_level: Dictionary[int, Dictionary]
var recruited_unit_types: Array[UnitType.Value]
var pending_explorations: Array[ExplorationOrder]
## Each value an `Array[GridPosition]`, in the order revealed.
var revealed_cells_per_level: Dictionary[int, Array]
var history_entries: Array[HistoryEntry]
var pending_reinforcements: Array[ReinforcementOrder]
var raid_state: RaidState
var worksite: Worksite
var volcano_state: VolcanoState
var event_state: EventState
var saved_objective_state: ObjectiveState
## Whether the base fell (a faction, after three raids lost in a row); null
## in the old saves, which never fell: false here.
var saved_fallen := false
## The scouts' reports on the other bases, by player id; null in the old
## saves: empty here.
var saved_intel: Dictionary[String, BaseIntel] = {}


## `Player(...)`: a collection or a state given as null takes the default
## of a new player, a new object each time; `id_` null draws a UUID.
func _init(
	name_: String,
	id_: Variant = null,
	base_x_ := 0,
	base_y_ := 0,
	resources_: Variant = null,
	buildings_: Variant = null,
	tech_branches_: Variant = null,
	units_per_level_: Variant = null,
	recruited_unit_types_: Array[UnitType.Value] = [],
	pending_explorations_: Array[ExplorationOrder] = [],
	revealed_cells_per_level_: Dictionary[int, Array] = {},
	history_entries_: Array[HistoryEntry] = [],
	pending_reinforcements_: Array[ReinforcementOrder] = [],
	raid_state_: RaidState = null,
	volcano_state_: VolcanoState = null,
	event_state_: EventState = null,
	objective_state_: ObjectiveState = null,
	worksite_: Worksite = null,
) -> void:
	name = name_
	id = id_ if id_ != null else UuidV4.generate()
	base_x = base_x_
	base_y = base_y_
	resources = resources_ if resources_ != null else PlayerDefaults.resources()
	buildings = buildings_ if buildings_ != null else PlayerDefaults.buildings()
	tech_branches = tech_branches_ if tech_branches_ != null else PlayerDefaults.tech_branches()
	units_per_level = units_per_level_ if units_per_level_ != null else PlayerDefaults.units_per_level()
	recruited_unit_types = recruited_unit_types_
	pending_explorations = pending_explorations_
	revealed_cells_per_level = revealed_cells_per_level_
	history_entries = history_entries_
	pending_reinforcements = pending_reinforcements_
	raid_state = raid_state_ if raid_state_ != null else RaidState.new()
	volcano_state = volcano_state_ if volcano_state_ != null else VolcanoState.new()
	event_state = event_state_ if event_state_ != null else EventState.new()
	saved_objective_state = objective_state_ if objective_state_ != null else ObjectiveState.new()
	worksite = worksite_ if worksite_ != null else Worksite.new()


## `Player.withBase`: a new player on its base, the square around it
## revealed on level 1.
static func with_base(
	name_: String, base_x_: int, base_y_: int, map_width: int, map_height: int,
	id_: Variant = null, history_entries_: Array[HistoryEntry] = [],
) -> Player:
	var revealed: Dictionary[int, Array] = {
		1: RevealAreaCalculator.around_base(base_x_, base_y_, map_width, map_height)
	}
	return Player.new(name_, id_, base_x_, base_y_, null, null, null, null, [], [], revealed, history_entries_)


func has_fallen() -> bool:
	return saved_fallen


## The reports of this player's scouts, by player id.
func intel() -> Dictionary[String, BaseIntel]:
	return saved_intel


## Whether the headquarters no longer meets what `type` needs.
func is_degraded(type: BuildingType.Value) -> bool:
	return BuildingDegradation.is_degraded(buildings, type)


## Lowers the headquarters by `levels`, never below level 1; returns its
## new level.
func lower_headquarters(levels: int) -> int:
	var hq: Building = buildings[BuildingType.Value.HEADQUARTERS]
	hq.level = maxi(1, hq.level - levels)
	return hq.level


## The units on `level`; a new empty map, not kept, when it has none.
func units_on_level(level: int) -> Dictionary[UnitType.Value, Unit]:
	return PlayerHoldings.units_on(units_per_level, level)


## Units on `level` by type, the empty types left out.
func unit_counts_on_level(level: int) -> Dictionary[UnitType.Value, int]:
	return PlayerHoldings.unit_counts(units_on_level(level))


## The cells revealed on `level`; a new empty list, not kept, when none.
func revealed_cells_on_level(level: int) -> Array[GridPosition]:
	return PlayerHoldings.cells_on(revealed_cells_per_level, level)


## `revealedCellsSetOnLevel`: the keys of the cells revealed, a set.
func revealed_cells_set_on_level(level: int) -> Dictionary[Vector2i, bool]:
	return PlayerHoldings.key_set(revealed_cells_on_level(level))


func revealed_cells() -> Dictionary[Vector2i, bool]:
	return revealed_cells_set_on_level(1)


func add_history_entry(entry: HistoryEntry) -> void:
	history_entries.append(entry)
	while history_entries.size() > HistoryConstants.K_HISTORY_MAX_ENTRIES:
		history_entries.remove_at(0)


func add_revealed_cell(level: int, pos: GridPosition) -> bool:
	if not revealed_cells_per_level.has(level):
		revealed_cells_per_level[level] = [] as Array[GridPosition]
	var cells: Array[GridPosition] = revealed_cells_per_level[level]
	if GridPosition.keys(cells).has(pos.key()):
		return false
	cells.append(pos)
	return true

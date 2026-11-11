class_name PlayerCodec
extends RefCounted
## A player of a save, the human or a faction, and everything it holds.
## Its maps keep their order, which the rules read (an army fights in it).


static func player(x: Player) -> Dictionary:
	var units := func(by_type: Dictionary) -> Variant: return _by_enum(by_type, UnitType.Value, BaseCodec.unit)
	var cells := func(revealed: Array) -> Variant: return SaveValues.list_of(revealed, MapCodec.position)
	var intel := {}
	for id: String in x.saved_intel:
		intel[id] = ThreatCodec.intel(x.saved_intel[id])
	return {
		"name": x.name, "id": x.id, "baseX": x.base_x, "baseY": x.base_y,
		"resources": _by_enum(x.resources, ResourceType.Value, BaseCodec.resource),
		"buildings": _by_enum(x.buildings, BuildingType.Value, BaseCodec.building),
		"techBranches": _by_enum(x.tech_branches, TechBranch.Value, BaseCodec.tech_branch),
		"unitsPerLevel": SaveValues.by_number(x.units_per_level, units),
		"recruitedUnitTypes": SaveValues.names(x.recruited_unit_types, UnitType.Value),
		"pendingExplorations": SaveValues.list_of(x.pending_explorations, OrderCodec.exploration),
		"revealedCellsPerLevel": SaveValues.by_number(x.revealed_cells_per_level, cells),
		"historyEntries": SaveValues.list_of(x.history_entries, HistoryCodec.entry),
		"pendingReinforcements": SaveValues.list_of(x.pending_reinforcements, OrderCodec.reinforcement),
		"raidState": ThreatCodec.raid(x.raid_state), "worksite": BaseCodec.worksite(x.worksite),
		"volcanoState": ThreatCodec.volcano(x.volcano_state), "eventState": EventCodec.event_state(x.event_state),
		"objectiveState": BaseCodec.objectives(x.saved_objective_state), "fallen": x.saved_fallen, "intel": intel,
	}


## Through the constructor, then the fields Dart's adapter sets after it.
static func read_player(r: SaveReader, value: Variant) -> Player:
	var m := r.object(value, "Player")
	var resources: Dictionary[ResourceType.Value, GameResource] = {}
	resources.assign(_read_by_enum(r, m, "resources", ResourceType.Value, BaseCodec.read_resource))
	var buildings: Dictionary[BuildingType.Value, Building] = {}
	buildings.assign(_read_by_enum(r, m, "buildings", BuildingType.Value, BaseCodec.read_building))
	var branches: Dictionary[TechBranch.Value, TechBranchState] = {}
	branches.assign(_read_by_enum(r, m, "techBranches", TechBranch.Value, BaseCodec.read_tech_branch))
	var units: Dictionary[int, Dictionary] = {}
	var revealed: Dictionary[int, Array] = {}
	var units_written := r.object_at(m, "unitsPerLevel")
	for level: Variant in units_written:
		var by_type: Dictionary[UnitType.Value, Unit] = {}
		by_type.assign(_read_by_enum(r, units_written, level, UnitType.Value, BaseCodec.read_unit))
		units[SaveCollections.number_key(r, r.text(level, "unitsPerLevel"), "unitsPerLevel")] = by_type
	var cells_written := r.object_at(m, "revealedCellsPerLevel")
	for level: Variant in cells_written:
		var cells: Array[GridPosition] = []
		cells.assign(SaveCollections.list_of(r, cells_written[level], "revealedCellsPerLevel", MapCodec.read_position))
		revealed[SaveCollections.number_key(r, r.text(level, "revealedCellsPerLevel"), "revealedCellsPerLevel")] = cells
	var explorations: Array[ExplorationOrder] = []
	explorations.assign(_list(r, m, "pendingExplorations", OrderCodec.read_exploration))
	var history: Array[HistoryEntry] = []
	history.assign(_list(r, m, "historyEntries", HistoryCodec.read_entry))
	var reinforcements: Array[ReinforcementOrder] = []
	reinforcements.assign(_list(r, m, "pendingReinforcements", OrderCodec.read_reinforcement))
	var found := Player.new(
		r.text_at(m, "name"), r.text_at(m, "id"), r.int_at(m, "baseX"), r.int_at(m, "baseY"), resources, buildings,
		branches, units, SaveCollections.names_at(r, m, "recruitedUnitTypes", UnitType.Value), explorations, revealed,
		history, reinforcements, ThreatCodec.read_raid(r, r.at(m, "raidState")),
		ThreatCodec.read_volcano(r, r.at(m, "volcanoState")), EventCodec.read_event_state(r, r.at(m, "eventState")),
		BaseCodec.read_objectives(r, r.at(m, "objectiveState")), BaseCodec.read_worksite(r, r.at(m, "worksite")),
	)
	found.saved_fallen = r.bool_at(m, "fallen")
	var intel := r.object_at(m, "intel")
	for id: Variant in intel:
		found.saved_intel[r.text(id, "intel")] = ThreatCodec.read_intel(r, intel[id])
	return found


## A map keyed by an enum, by the Dart names of its keys.
static func _by_enum(map: Dictionary, enumeration: Dictionary, write: Callable) -> Dictionary:
	var written := {}
	for key: int in map:
		written[SaveValues.name(enumeration, key)] = write.call(map[key])
	return written


static func _read_by_enum(r: SaveReader, m: Dictionary, key: Variant, enumeration: Dictionary, read: Callable) -> Dictionary:
	var what := r.text(key, "map")
	var found := {}
	var written := r.object(r.at(m, what), what)
	for name: Variant in written:
		found[r.enum_value(name, enumeration, what)] = read.call(r, written[name])
	return found


static func _list(r: SaveReader, m: Dictionary, key: String, read: Callable) -> Array:
	return SaveCollections.list_of(r, r.at(m, key), key, read)

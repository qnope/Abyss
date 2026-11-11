class_name PlayerSnapshots
extends RefCounted
## lib/domain/reference/snapshots/player_snapshots.dart: snapshot of a
## player, human or faction, and of its objectives.


static func objectives() -> ClassSnapshot:
	return ClassSnapshot.new("ObjectiveState", {
		"completed": func(o: ObjectiveState, _ids: PlayerIds) -> Variant: return SnapshotValues.names(o.completed, ObjectiveId.Value),
		"tutorialEnabled": func(o: ObjectiveState, _ids: PlayerIds) -> Variant: return o.tutorial_enabled,
		"tipsEnabled": func(o: ObjectiveState, _ids: PlayerIds) -> Variant: return o.tips_enabled,
		"seenTips": func(o: ObjectiveState, _ids: PlayerIds) -> Variant: return SnapshotValues.names(o.seen_tips, TipId.Value),
	})


static func player() -> ClassSnapshot:
	var resources := BaseSnapshots.resource()
	var buildings := BaseSnapshots.building()
	var branches := BaseSnapshots.tech_branch()
	var units := BaseSnapshots.unit()
	var explorations := MapSnapshots.exploration()
	var positions := MapSnapshots.position()
	var entries := HistorySnapshots.by_category()
	var reinforcements := MapSnapshots.reinforcement()
	var raids := ThreatSnapshots.raid()
	var worksites := BaseSnapshots.worksite()
	var volcanoes := ThreatSnapshots.volcano()
	var events := ThreatSnapshots.event()
	var objective_states := objectives()
	var intel := ThreatSnapshots.intel()
	var level := func(key: int) -> Variant: return key
	return ClassSnapshot.new("Player", {
		"name": func(p: Player, _ids: PlayerIds) -> Variant: return p.name,
		"id": func(p: Player, ids: PlayerIds) -> Variant: return ids.of(p.id),
		"baseX": func(p: Player, _ids: PlayerIds) -> Variant: return p.base_x,
		"baseY": func(p: Player, _ids: PlayerIds) -> Variant: return p.base_y,
		"resources": func(p: Player, ids: PlayerIds) -> Variant:
			return SnapshotValues.pairs(p.resources, _namer(ResourceType.Value), _writer(resources, ids)),
		"buildings": func(p: Player, ids: PlayerIds) -> Variant:
			return SnapshotValues.pairs(p.buildings, _namer(BuildingType.Value), _writer(buildings, ids)),
		"techBranches": func(p: Player, ids: PlayerIds) -> Variant:
			return SnapshotValues.pairs(p.tech_branches, _namer(TechBranch.Value), _writer(branches, ids)),
		"unitsPerLevel": func(p: Player, ids: PlayerIds) -> Variant:
			var on_level := func(by_type: Dictionary) -> Variant:
				return SnapshotValues.pairs(by_type, _namer(UnitType.Value), _writer(units, ids))
			return SnapshotValues.pairs(p.units_per_level, level, on_level),
		"recruitedUnitTypes": func(p: Player, _ids: PlayerIds) -> Variant:
			return SnapshotValues.names(p.recruited_unit_types, UnitType.Value),
		"pendingExplorations": func(p: Player, ids: PlayerIds) -> Variant:
			return explorations.list_of(p.pending_explorations, ids),
		"revealedCellsPerLevel": func(p: Player, ids: PlayerIds) -> Variant:
			var cells := func(revealed: Array) -> Variant: return positions.list_of(revealed, ids)
			return SnapshotValues.pairs(p.revealed_cells_per_level, level, cells),
		"historyEntries": func(p: Player, ids: PlayerIds) -> Variant:
			var written: Array = []
			for e: HistoryEntry in p.history_entries:
				written.append(entries[e.category].of(e, ids))
			return written,
		"pendingReinforcements": func(p: Player, ids: PlayerIds) -> Variant:
			return reinforcements.list_of(p.pending_reinforcements, ids),
		"raidState": func(p: Player, ids: PlayerIds) -> Variant: return raids.of(p.raid_state, ids),
		"worksite": func(p: Player, ids: PlayerIds) -> Variant: return worksites.of(p.worksite, ids),
		"volcanoState": func(p: Player, ids: PlayerIds) -> Variant: return volcanoes.of(p.volcano_state, ids),
		"eventState": func(p: Player, ids: PlayerIds) -> Variant: return events.of(p.event_state, ids),
		"savedObjectiveState": func(p: Player, ids: PlayerIds) -> Variant:
			return objective_states.or_null(p.saved_objective_state, ids),
		"savedFallen": func(p: Player, _ids: PlayerIds) -> Variant: return p.has_fallen(),
		"savedIntel": func(p: Player, ids: PlayerIds) -> Variant:
			return SnapshotValues.pairs(p.saved_intel, ids.of, _writer(intel, ids)),
	}, {"savedObjectiveState": "objectiveState", "savedFallen": "fallen", "savedIntel": "intel"})


## Not in the Dart class: `SnapshotValues.name` as a tear-off, for the keys
## of `enumeration`.
static func _namer(enumeration: Dictionary) -> Callable:
	return func(value: int) -> Variant: return SnapshotValues.name(enumeration, value)


## Not in the Dart class: `(x) => snapshot.of(x, ids)`.
static func _writer(snapshot: ClassSnapshot, ids: PlayerIds) -> Callable:
	return func(value: Object) -> Variant: return snapshot.of(value, ids)

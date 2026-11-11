class_name HistorySnapshots
extends RefCounted
## lib/domain/reference/snapshots/history_snapshots.dart: snapshots of the
## history entries that hold no fight, and the way to write any entry.

const Category := HistoryEntryCategory.Value


## The snapshot of `entry`, whatever its class; its `category` tells the
## classes apart, one each.
static func of(entry: HistoryEntry, ids: PlayerIds) -> Dictionary:
	return by_category()[entry.category].of(entry, ids)


## Not in the Dart class: the snapshot of each class of entry by its
## category, what `of` switches on, built once for a whole history.
static func by_category() -> Dictionary[HistoryEntryCategory.Value, ClassSnapshot]:
	return {
		Category.BUILDING: building(), Category.COLLECT: collect(), Category.EXPLORE: explore(),
		Category.RECRUIT: recruit(), Category.RESEARCH: research(), Category.TURN_END: turn_end(),
		Category.DESCENT: descent(), Category.REINFORCEMENT: reinforcement(), Category.EVENT: event(),
		Category.COMBAT: HistoryFightSnapshots.combat(), Category.CAPTURE: HistoryFightSnapshots.capture(),
		Category.RAID: HistoryFightSnapshots.raid(), Category.VOLCANO: HistoryFightSnapshots.volcano(),
		Category.ASSAULT: HistoryFightSnapshots.assault(),
	}


static func building() -> ClassSnapshot:
	return HistoryEntrySnapshot.of("BuildingEntry", {
		"buildingType": func(e: BuildingEntry, _ids: PlayerIds) -> Variant:
			return SnapshotValues.name(BuildingType.Value, e.building_type),
		"newLevel": func(e: BuildingEntry, _ids: PlayerIds) -> Variant: return e.new_level,
	})


static func collect() -> ClassSnapshot:
	return HistoryEntrySnapshot.of("CollectEntry", {
		"targetX": func(e: CollectEntry, _ids: PlayerIds) -> Variant: return e.target_x,
		"targetY": func(e: CollectEntry, _ids: PlayerIds) -> Variant: return e.target_y,
		"gains": func(e: CollectEntry, _ids: PlayerIds) -> Variant: return SnapshotValues.counts(e.gains, ResourceType.Value),
	})


static func explore() -> ClassSnapshot:
	return HistoryEntrySnapshot.of("ExploreEntry", {
		"targetX": func(e: ExploreEntry, _ids: PlayerIds) -> Variant: return e.target_x,
		"targetY": func(e: ExploreEntry, _ids: PlayerIds) -> Variant: return e.target_y,
	})


static func recruit() -> ClassSnapshot:
	return HistoryEntrySnapshot.of("RecruitEntry", {
		"unitType": func(e: RecruitEntry, _ids: PlayerIds) -> Variant: return SnapshotValues.name(UnitType.Value, e.unit_type),
		"quantity": func(e: RecruitEntry, _ids: PlayerIds) -> Variant: return e.quantity,
	})


static func research() -> ClassSnapshot:
	return HistoryEntrySnapshot.of("ResearchEntry", {
		"branch": func(e: ResearchEntry, _ids: PlayerIds) -> Variant: return SnapshotValues.name(TechBranch.Value, e.branch),
		"isUnlock": func(e: ResearchEntry, _ids: PlayerIds) -> Variant: return e.is_unlock,
		"newLevel": func(e: ResearchEntry, _ids: PlayerIds) -> Variant: return e.new_level,
	})


static func resource_change() -> ClassSnapshot:
	return ClassSnapshot.new("TurnResourceChange", {
		"type": func(c: TurnResourceChange, _ids: PlayerIds) -> Variant: return SnapshotValues.name(ResourceType.Value, c.type),
		"produced": func(c: TurnResourceChange, _ids: PlayerIds) -> Variant: return c.produced,
		"consumed": func(c: TurnResourceChange, _ids: PlayerIds) -> Variant: return c.consumed,
		"wasCapped": func(c: TurnResourceChange, _ids: PlayerIds) -> Variant: return c.was_capped,
		"beforeAmount": func(c: TurnResourceChange, _ids: PlayerIds) -> Variant: return c.before_amount,
		"afterAmount": func(c: TurnResourceChange, _ids: PlayerIds) -> Variant: return c.after_amount,
	})


static func turn_end() -> ClassSnapshot:
	var changes := resource_change()
	return HistoryEntrySnapshot.of("TurnEndEntry", {
		"changes": func(e: TurnEndEntry, ids: PlayerIds) -> Variant: return changes.list_of(e.changes, ids),
		"deactivatedBuildings": func(e: TurnEndEntry, _ids: PlayerIds) -> Variant:
			return SnapshotValues.names(e.deactivated_buildings, BuildingType.Value),
		"lostUnits": func(e: TurnEndEntry, _ids: PlayerIds) -> Variant: return SnapshotValues.counts(e.lost_units, UnitType.Value),
	})


static func descent() -> ClassSnapshot:
	return HistoryEntrySnapshot.of("DescentEntry", {
		"targetLevel": func(e: DescentEntry, _ids: PlayerIds) -> Variant: return e.target_level,
		"unitCount": func(e: DescentEntry, _ids: PlayerIds) -> Variant: return e.unit_count,
	})


static func reinforcement() -> ClassSnapshot:
	return HistoryEntrySnapshot.of("ReinforcementEntry", {
		"targetLevel": func(e: ReinforcementEntry, _ids: PlayerIds) -> Variant: return e.target_level,
		"unitCount": func(e: ReinforcementEntry, _ids: PlayerIds) -> Variant: return e.unit_count,
	})


static func event() -> ClassSnapshot:
	return HistoryEntrySnapshot.of("EventEntry", {
		"type": func(e: EventEntry, _ids: PlayerIds) -> Variant: return SnapshotValues.name(RandomEventType.Value, e.type),
		"accepted": func(e: EventEntry, _ids: PlayerIds) -> Variant: return e.accepted,
		"defaulted": func(e: EventEntry, _ids: PlayerIds) -> Variant: return e.defaulted,
	})


## Every class of entry, for the completeness guard.
static func all() -> Array[ClassSnapshot]:
	var found: Array[ClassSnapshot] = [
		building(), collect(), explore(), recruit(), research(), resource_change(), turn_end(), descent(),
		reinforcement(), event(),
	]
	found.append_array(HistoryFightSnapshots.all())
	return found

class_name HistoryCodec
extends RefCounted
## The history of a player, in a save: each entry its turn, its category,
## which tells the classes apart, and its own fields. The entries that hold
## a fight are HistoryFightCodec's.

const Category := HistoryEntryCategory.Value


static func entry(x: HistoryEntry) -> Dictionary:
	var written := {"turn": x.turn, "category": SaveValues.name(Category, x.category)}
	written.merge(HistoryFightCodec.own(x) if HistoryFightCodec.FIGHTS.has(x.category) else _own(x))
	return written


static func read_entry(r: SaveReader, value: Variant) -> HistoryEntry:
	var m := r.object(value, "HistoryEntry")
	var turn := r.int_at(m, "turn")
	var category: Category = r.enum_at(m, "category", Category)
	if HistoryFightCodec.FIGHTS.has(category):
		return HistoryFightCodec.read_own(r, m, turn, category)
	match category:
		Category.COLLECT:
			return CollectEntry.new(
				turn, r.int_at(m, "targetX"), r.int_at(m, "targetY"),
				SaveCollections.counts_at(r, m, "gains", ResourceType.Value))
		Category.EXPLORE:
			return ExploreEntry.new(turn, r.int_at(m, "targetX"), r.int_at(m, "targetY"))
		Category.RECRUIT:
			return RecruitEntry.new(turn, r.enum_at(m, "unitType", UnitType.Value), r.int_at(m, "quantity"))
		Category.RESEARCH:
			return ResearchEntry.new(
				turn, r.enum_at(m, "branch", TechBranch.Value), r.bool_at(m, "isUnlock"), r.int_or_null_at(m, "newLevel"))
		Category.TURN_END:
			var changes: Array[TurnResourceChange] = []
			changes.assign(SaveCollections.list_of(r, r.at(m, "changes"), "changes", read_change))
			return TurnEndEntry.new(
				turn, changes, SaveCollections.names_at(r, m, "deactivatedBuildings", BuildingType.Value),
				SaveCollections.counts_at(r, m, "lostUnits", UnitType.Value))
		Category.DESCENT:
			return DescentEntry.new(turn, r.int_at(m, "targetLevel"), r.int_at(m, "unitCount"))
		Category.REINFORCEMENT:
			return ReinforcementEntry.new(turn, r.int_at(m, "targetLevel"), r.int_at(m, "unitCount"))
		Category.EVENT:
			return EventEntry.new(
				turn, r.enum_at(m, "type", RandomEventType.Value), r.bool_at(m, "accepted"), r.bool_at(m, "defaulted"))
	# Category.BUILDING, and what a bad category reads as.
	return BuildingEntry.new(turn, r.enum_at(m, "buildingType", BuildingType.Value), r.int_at(m, "newLevel"))


static func change(x: TurnResourceChange) -> Dictionary:
	return {
		"type": SaveValues.name(ResourceType.Value, x.type), "produced": x.produced, "consumed": x.consumed,
		"wasCapped": x.was_capped, "beforeAmount": x.before_amount, "afterAmount": x.after_amount,
	}


static func read_change(r: SaveReader, value: Variant) -> TurnResourceChange:
	var m := r.object(value, "TurnResourceChange")
	return TurnResourceChange.new(
		r.enum_at(m, "type", ResourceType.Value), r.int_at(m, "produced"), r.bool_at(m, "wasCapped"),
		r.int_at(m, "beforeAmount"), r.int_at(m, "afterAmount"), r.int_at(m, "consumed"),
	)


static func _own(x: HistoryEntry) -> Dictionary:
	match x.category:
		Category.COLLECT:
			var e := x as CollectEntry
			return {"targetX": e.target_x, "targetY": e.target_y, "gains": SaveValues.counts(e.gains, ResourceType.Value)}
		Category.EXPLORE:
			var e := x as ExploreEntry
			return {"targetX": e.target_x, "targetY": e.target_y}
		Category.RECRUIT:
			var e := x as RecruitEntry
			return {"unitType": SaveValues.name(UnitType.Value, e.unit_type), "quantity": e.quantity}
		Category.RESEARCH:
			var e := x as ResearchEntry
			return {"branch": SaveValues.name(TechBranch.Value, e.branch), "isUnlock": e.is_unlock, "newLevel": e.new_level}
		Category.TURN_END:
			var e := x as TurnEndEntry
			return {
				"changes": SaveValues.list_of(e.changes, change),
				"deactivatedBuildings": SaveValues.names(e.deactivated_buildings, BuildingType.Value),
				"lostUnits": SaveValues.counts(e.lost_units, UnitType.Value),
			}
		Category.DESCENT:
			var e := x as DescentEntry
			return {"targetLevel": e.target_level, "unitCount": e.unit_count}
		Category.REINFORCEMENT:
			var e := x as ReinforcementEntry
			return {"targetLevel": e.target_level, "unitCount": e.unit_count}
		Category.EVENT:
			var e := x as EventEntry
			return {"type": SaveValues.name(RandomEventType.Value, e.type), "accepted": e.accepted, "defaulted": e.defaulted}
	# Category.BUILDING
	var b := x as BuildingEntry
	return {"buildingType": SaveValues.name(BuildingType.Value, b.building_type), "newLevel": b.new_level}

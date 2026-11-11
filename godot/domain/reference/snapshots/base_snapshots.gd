class_name BaseSnapshots
extends RefCounted
## lib/domain/reference/snapshots/base_snapshots.dart: snapshots of what a
## base holds, stocks, buildings, research, units and the work started this
## turn. A table of functions cannot be a constant: each function builds
## its snapshot.


static func resource() -> ClassSnapshot:
	return ClassSnapshot.new("Resource", {
		"type": func(r: GameResource, _ids: PlayerIds) -> Variant: return SnapshotValues.name(ResourceType.Value, r.type),
		"amount": func(r: GameResource, _ids: PlayerIds) -> Variant: return r.amount,
		"maxStorage": func(r: GameResource, _ids: PlayerIds) -> Variant: return r.max_storage,
	})


static func building() -> ClassSnapshot:
	return ClassSnapshot.new("Building", {
		"type": func(b: Building, _ids: PlayerIds) -> Variant: return SnapshotValues.name(BuildingType.Value, b.type),
		"level": func(b: Building, _ids: PlayerIds) -> Variant: return b.level,
	})


static func tech_branch() -> ClassSnapshot:
	return ClassSnapshot.new("TechBranchState", {
		"branch": func(t: TechBranchState, _ids: PlayerIds) -> Variant: return SnapshotValues.name(TechBranch.Value, t.branch),
		"unlocked": func(t: TechBranchState, _ids: PlayerIds) -> Variant: return t.unlocked,
		"researchLevel": func(t: TechBranchState, _ids: PlayerIds) -> Variant: return t.research_level,
		"choices": func(t: TechBranchState, _ids: PlayerIds) -> Variant: return Array(t.choices),
	})


static func unit() -> ClassSnapshot:
	return ClassSnapshot.new("Unit", {
		"type": func(u: Unit, _ids: PlayerIds) -> Variant: return SnapshotValues.name(UnitType.Value, u.type),
		"count": func(u: Unit, _ids: PlayerIds) -> Variant: return u.count,
	})


static func worksite() -> ClassSnapshot:
	return ClassSnapshot.new("Worksite", {
		"upgrades": func(w: Worksite, _ids: PlayerIds) -> Variant: return w.upgrades,
		"research": func(w: Worksite, _ids: PlayerIds) -> Variant: return w.research,
	})

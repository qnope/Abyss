class_name BaseCodec
extends RefCounted
## What a base holds, in a save: stocks, buildings, research, units, the
## work started this turn and the objectives. Each object is read back
## through its constructor, as the Hive adapters of Dart read it.


static func resource(x: GameResource) -> Dictionary:
	return {"type": SaveValues.name(ResourceType.Value, x.type), "amount": x.amount, "maxStorage": x.max_storage}


## Through the constructor, which lifts a small energy storage as Dart's does.
static func read_resource(r: SaveReader, value: Variant) -> GameResource:
	var m := r.object(value, "Resource")
	return GameResource.new(r.enum_at(m, "type", ResourceType.Value), r.int_at(m, "amount"), r.int_at(m, "maxStorage"))


static func building(x: Building) -> Dictionary:
	return {"type": SaveValues.name(BuildingType.Value, x.type), "level": x.level}


static func read_building(r: SaveReader, value: Variant) -> Building:
	var m := r.object(value, "Building")
	return Building.new(r.enum_at(m, "type", BuildingType.Value), r.int_at(m, "level"))


static func tech_branch(x: TechBranchState) -> Dictionary:
	return {
		"branch": SaveValues.name(TechBranch.Value, x.branch), "unlocked": x.unlocked,
		"researchLevel": x.research_level, "choices": x.choices.duplicate(),
	}


static func read_tech_branch(r: SaveReader, value: Variant) -> TechBranchState:
	var m := r.object(value, "TechBranchState")
	return TechBranchState.new(
		r.enum_at(m, "branch", TechBranch.Value), r.bool_at(m, "unlocked"), r.int_at(m, "researchLevel"),
		SaveCollections.ints_at(r, m, "choices"),
	)


static func unit(x: Unit) -> Dictionary:
	return {"type": SaveValues.name(UnitType.Value, x.type), "count": x.count}


static func read_unit(r: SaveReader, value: Variant) -> Unit:
	var m := r.object(value, "Unit")
	return Unit.new(r.enum_at(m, "type", UnitType.Value), r.int_at(m, "count"))


static func worksite(x: Worksite) -> Dictionary:
	return {"upgrades": x.upgrades, "research": x.research}


static func read_worksite(r: SaveReader, value: Variant) -> Worksite:
	var m := r.object(value, "Worksite")
	return Worksite.new(r.int_at(m, "upgrades"), r.int_at(m, "research"))


static func objectives(x: ObjectiveState) -> Dictionary:
	return {
		"completed": SaveValues.names(x.completed, ObjectiveId.Value), "tutorialEnabled": x.tutorial_enabled,
		"tipsEnabled": x.tips_enabled, "seenTips": SaveValues.names(x.seen_tips, TipId.Value),
	}


static func read_objectives(r: SaveReader, value: Variant) -> ObjectiveState:
	var m := r.object(value, "ObjectiveState")
	return ObjectiveState.new(
		SaveCollections.names_at(r, m, "completed", ObjectiveId.Value), r.bool_at(m, "tutorialEnabled"),
		r.bool_at(m, "tipsEnabled"), SaveCollections.names_at(r, m, "seenTips", TipId.Value),
	)

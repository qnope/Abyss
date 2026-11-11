class_name WorldModels
extends RefCounted
## The one place that says what a building of the base looks like: the model
## of assets/models/ when there is one, a [StandIn] when there is not. The
## base asks here and nowhere else, so that step 7 only adds models to
## [constant MODELS] (and their animations), touching neither the interface
## nor app/.
##
## How much of a degraded model's look the grey veil takes.
const VEIL := 0.6

## A building is placed by its origin, the top centre of its pad.

## The buildings that have a model, by type.
const MODELS: Dictionary[BuildingType.Value, PackedScene] = {
	BuildingType.Value.HEADQUARTERS: preload("res://assets/models/headquarters.glb"),
	BuildingType.Value.SOLAR_PANEL: preload("res://assets/models/solar_panel.glb"),
	BuildingType.Value.CORAL_CITADEL: preload("res://assets/models/coral_citadel.glb"),
}


## The units that have a model, by type: one figure of a squad. None yet; step
## 7 adds them here.
const UNIT_MODELS: Dictionary[UnitType.Value, PackedScene] = {}


## Whether the building [param type] has a model.
static func has_model(type: BuildingType.Value) -> bool:
	return MODELS.has(type)


## The building [param type] at [param level] (1 or more), greyed when
## [param degraded]: its model, or its stand-in when it has none or
## [param models] is false (the stand-ins alone, for a review).
static func building(
	type: BuildingType.Value, level := 1, degraded := false, models := true
) -> Node3D:
	if not (models and has_model(type)):
		return StandIn.new(type, level, degraded)
	var model := MODELS[type].instantiate() as Node3D
	if degraded:
		_grey(model)
	return model


## One figure of the squad of the unit [param type], its origin the floor
## under it: its model, or its stand-in when it has none in [param models]
## (the units' [constant UNIT_MODELS]; a test gives its own). A [param ghost]
## is a locked unit's, greyed and half there.
static func unit(
	type: UnitType.Value, ghost := false, models: Dictionary[UnitType.Value, PackedScene] = UNIT_MODELS
) -> Node3D:
	if not models.has(type):
		return UnitStandIn.new(type, ghost)
	var model := models[type].instantiate() as Node3D
	if ghost:
		_grey(model)
	return model


## The stand-in of the building [param type], whether it has a model or not.
static func stand_in(type: BuildingType.Value, level := 1, degraded := false) -> StandIn:
	return StandIn.new(type, level, degraded)


## Dulls every mesh of [param model] under a veil of the degraded grey, which
## leaves the detail of its colours under it.
static func _grey(model: Node3D) -> void:
	var veil := StandardMaterial3D.new()
	veil.albedo_color = Color(WorldPalette.DEGRADED, VEIL)
	veil.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for node: Node in model.find_children("*", "GeometryInstance3D", true, false):
		(node as GeometryInstance3D).material_overlay = veil

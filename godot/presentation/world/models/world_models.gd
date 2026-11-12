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
	BuildingType.Value.ALGAE_FARM: preload("res://assets/models/algae_farm.glb"),
	BuildingType.Value.CORAL_MINE: preload("res://assets/models/coral_mine.glb"),
	BuildingType.Value.ORE_EXTRACTOR: preload("res://assets/models/ore_extractor.glb"),
	BuildingType.Value.SOLAR_PANEL: preload("res://assets/models/solar_panel.glb"),
	BuildingType.Value.LABORATORY: preload("res://assets/models/laboratory.glb"),
	BuildingType.Value.BARRACKS: preload("res://assets/models/barracks.glb"),
	BuildingType.Value.CORAL_CITADEL: preload("res://assets/models/coral_citadel.glb"),
	BuildingType.Value.DESCENT_MODULE: preload("res://assets/models/descent_module.glb"),
	BuildingType.Value.PRESSURE_CAPSULE: preload("res://assets/models/pressure_capsule.glb"),
	BuildingType.Value.VOLCANIC_KERNEL: preload("res://assets/models/volcanic_kernel.glb"),
}


## The units that have a model, by type: one figure of a squad.
const UNIT_MODELS: Dictionary[UnitType.Value, PackedScene] = {
	UnitType.Value.SCOUT: preload("res://assets/models/scout.glb"),
	UnitType.Value.HARPOONIST: preload("res://assets/models/harpoonist.glb"),
	UnitType.Value.GUARDIAN: preload("res://assets/models/guardian.glb"),
	UnitType.Value.DOME_BREAKER: preload("res://assets/models/dome_breaker.glb"),
	UnitType.Value.ABYSS_ADMIRAL: preload("res://assets/models/abyss_admiral.glb"),
	UnitType.Value.SABOTEUR: preload("res://assets/models/saboteur.glb"),
}
## The units are modelled facing -Z: this turns a figure to the game's camera.
const FIGURE_YAW := -135.0
## The meta of a figure that holds its [ModelAnimator].
const ANIMATOR := &"animator"


## The contents of the map that have a model, by kind. None yet; step 7 adds
## them here.
const MAP_MODELS: Dictionary[MapContent.Kind, PackedScene] = {}


## Whether the building [param type] has a model.
static func has_model(type: BuildingType.Value) -> bool:
	return MODELS.has(type)


## The building [param type] at [param level] (1 or more), greyed when
## [param degraded]: its model (showing the tiers its level has risen to,
## [BuildingTier], when it has any), or its stand-in when it has none or
## [param models] is false (the stand-ins alone, for a review).
static func building(
	type: BuildingType.Value, level := 1, degraded := false, models := true
) -> Node3D:
	if not (models and has_model(type)):
		return StandIn.new(type, level, degraded)
	var model := MODELS[type].instantiate() as Node3D
	ModelTiers.show_up_to(model, BuildingTier.of_level(level))
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
	model.rotation_degrees.y = FIGURE_YAW
	model.set_meta(ANIMATOR, ModelAnimator.new(model))
	if ghost:
		_grey(model)
	return model


## The animator of a [param figure] of [method unit], or null for a stand-in.
static func animator(figure: Node) -> ModelAnimator:
	if not figure.has_meta(ANIMATOR):
		return null
	var held: Object = figure.get_meta(ANIMATOR)
	return held as ModelAnimator


## What stands on a cell of the map, its origin the floor under the cell's
## centre (the middle of the four cells of the volcano): the model of the
## [param kind] when [param models] has one (this file's [constant MAP_MODELS]; a
## test gives its own), else its [MapStandIn]. [param tint] (a Color, or null)
## is the colour of whoever holds a post, a rival base, or the seal of the
## volcano; [param dimmed] is a content already emptied, in the degraded grey.
static func map_content(
	kind: MapContent.Kind, tint: Variant = null, dimmed := false,
	models: Dictionary[MapContent.Kind, PackedScene] = MAP_MODELS
) -> Node3D:
	if not models.has(kind):
		return MapStandIn.new(kind, tint, dimmed)
	var model := models[kind].instantiate() as Node3D
	if dimmed:
		_grey(model)
	return model


## The floor of a cell of [param terrain], [param revealed] or under the fog: a
## colour and the height of its top.
static func terrain(terrain_: TerrainType.Value, revealed: bool) -> TerrainLook:
	return TerrainLook.of(terrain_, revealed)


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

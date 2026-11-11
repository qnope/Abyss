class_name BuildingView
extends RefCounted
## What the sheet of a building reads of the game, taken at one moment: the
## building and the player's stock, buildings and worksite, its readiness to
## rise (the bases and the kernel captured, the research's discount) and
## the headquarters level it lacks if it is degraded. The parts of the sheet
## are built from it, so that each is tested on its own.

var type: BuildingType.Value
var building: Building
var resources: Dictionary[ResourceType.Value, GameResource]
var buildings: Dictionary[BuildingType.Value, Building]
var worksite: Worksite
var calculator: BuildingCostCalculator
var readiness: UpgradeReadiness
## The headquarters level the building lacks (an int), null if not degraded.
var missing_headquarters: Variant


## The view of the building [param type_] of the human player of [param game].
static func of(game: Game, type_: BuildingType.Value) -> BuildingView:
	var human := game.human_player()
	var view := BuildingView.new()
	view.type = type_
	view.building = human.buildings[type_]
	view.resources = human.resources
	view.buildings = human.buildings
	view.worksite = human.worksite
	view.calculator = BuildingCostCalculator.new(TechEffects.of(human).upgrade_discount_percent())
	view.readiness = GameUpgradeReadiness.upgrade_readiness_of(game, human, type_)
	view.missing_headquarters = BuildingDegradation.missing_headquarters(view.buildings, type_)
	return view


func is_built() -> bool:
	return building.level > 0


## The level of the building [param other] in the base.
func level_of(other: BuildingType.Value) -> int:
	return Building.level_in(buildings, other)

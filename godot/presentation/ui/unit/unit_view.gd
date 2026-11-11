class_name UnitView
extends RefCounted
## What the sheet of a unit reads of the game, taken at one moment: the unit,
## how many serve where the player looks, the barracks' level, which unlocks
## it, the stock that pays for recruits and how many it pays for, whether the
## type was recruited this turn already and whether the barracks is degraded
## (every unit then costs twice as much). The parts of the sheet are built from
## it (game_screen_actions.dart: showUnitDetailAction).

var type: UnitType.Value
## Units of the type serving at the place the player looks at.
var count: int
var barracks_level: int
var resources: Dictionary[ResourceType.Value, GameResource]
var calculator := UnitCostCalculator.new()
var recruited_this_turn: bool
## The barracks are degraded: every unit costs twice as much.
var cost_doubled: bool


## The view of [param type_] in the game of [param game], [param count_] of
## them serving where the player looks.
static func of(game: Game, type_: UnitType.Value, count_: int) -> UnitView:
	var human := game.human_player()
	var view := UnitView.new()
	view.type = type_
	view.count = count_
	view.barracks_level = Building.level_in(human.buildings, BuildingType.Value.BARRACKS)
	view.resources = human.resources
	view.recruited_this_turn = human.recruited_unit_types.has(type_)
	view.cost_doubled = human.is_degraded(BuildingType.Value.BARRACKS)
	return view


## Whether the barracks is high enough for the unit.
func is_unlocked() -> bool:
	return calculator.is_unlocked(type, barracks_level)


## The barracks level that unlocks the unit.
func unlock_level() -> int:
	return calculator.unlock_level(type)


## How many of the unit the stock pays for, at the barracks' price.
func max_recruitable() -> int:
	return calculator.max_recruitable_count(type, barracks_level, resources, cost_doubled)


## What one unit costs, at the barracks' price.
func unit_cost() -> Dictionary[ResourceType.Value, int]:
	return calculator.recruitment_cost(type, cost_doubled)

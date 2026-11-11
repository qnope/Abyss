class_name AssaultPlans
extends RefCounted
## The plans of the assaults the player can lead on what nobody holds yet (a
## Faille, a Cheminée or the volcanic kernel), as the panels the sheets and
## the army selections show (lib/presentation/screens/game/
## game_screen_assault_plan.dart: `assaultPlanAt`). They are built here and not
## by a static function of the panel itself (a node class that builds itself
## in a static function leaks its script, Godot 4.7).
##
## The sheet shows the plan of sending every unit of the level; the selection
## starts from no unit and follows the picks ([method track]).


## The plan of the human's assault on the target still to capture at ([param x],
## [param y]) of [param level], sending [param army]; null when there is nothing
## to capture there.
static func plan_at(game: Game, level: int, x: int, y: int, army: Dictionary[UnitType.Value, int]) -> AssaultPlan:
	var found: Variant = AssaultTarget.at(game, level, x, y)
	if found == null:
		return null
	var target: AssaultTarget.Value = found
	return AssaultPlan.of(game.human_player(), level, target, army)


## The panel of the plan that sends every unit of [param level], for a sheet;
## null when there is nothing to capture at ([param x], [param y]).
static func sheet_panel(game: Game, level: int, x: int, y: int) -> AssaultPlanPanel:
	var everyone: Dictionary[UnitType.Value, int] = {}
	var stock := game.human_player().units_on_level(level)
	for type: UnitType.Value in stock:
		everyone[type] = stock[type].count
	return _panel(plan_at(game, level, x, y, everyone), level)


## The panel of the plan that sends no unit yet, for an army selection (to
## [method track]); null when there is nothing to capture at ([param x],
## [param y]).
static func selection_panel(game: Game, level: int, x: int, y: int) -> AssaultPlanPanel:
	return _panel(plan_at(game, level, x, y, {}), level)


## Has [param panel] follow the units [param page] has picked.
static func track(page: ArmySelection, panel: AssaultPlanPanel, game: Game, level: int, x: int, y: int) -> void:
	if panel != null:
		page.picks_changed.connect(follow.bind(panel, game, level, x, y))


## Shows on [param panel] the plan of the [param chosen] army.
static func follow(chosen: Dictionary[UnitType.Value, int], panel: AssaultPlanPanel, game: Game, level: int, x: int, y: int) -> void:
	var plan := plan_at(game, level, x, y, chosen)
	if plan != null:
		panel.show_plan(plan)


static func _panel(plan: AssaultPlan, level: int) -> AssaultPlanPanel:
	return null if plan == null else AssaultPlanPanel.new(plan, level)

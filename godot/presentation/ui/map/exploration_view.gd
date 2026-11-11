class_name ExplorationView
extends RefCounted
## What the exploration sheet tells about sending a scout to a hidden cell,
## read from the game at one moment (lib/presentation/screens/game/
## game_screen_exploration_flow.dart): the scouts there are on the level, how
## wide an area a scout reveals, the noise the sending makes, and why it cannot
## be sent now, if it cannot.

var x: int
var y: int
var level: int
## The scouts serving on the level.
var scout_count: int
## The side, in cells, of the square a scout reveals.
var reveal_side: int
## The raid gauge the exploration fills.
var noise: int
## Why the scout cannot go (an ActionFailure.Value: a storm, no scout, a cell
## too far), or null when it can.
var reason: Variant


static func of(game: Game, x_: int, y_: int, level_: int) -> ExplorationView:
	var human := game.human_player()
	var action := ExploreAction.new(x_, y_, level_)
	var view := ExplorationView.new()
	view.x = x_
	view.y = y_
	view.level = level_
	view.scout_count = Unit.count_in(human.units_on_level(level_), UnitType.Value.SCOUT)
	view.reveal_side = TechEffects.of(human).reveal_side()
	view.noise = action.noise_made(human)
	view.reason = action.validate(game, human).reason
	return view

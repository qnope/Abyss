class_name MapTab
extends RefreshingPanel
## The 2D part of the map tab, over the map in 3D (lib/presentation/screens/
## game/game_screen_map_actions.dart, `buildMapTab`): the selector of levels,
## floating at the top. Everything else is the map's, which answers the touches
## of the player.
##
## The level shown is the tab's own, not saved. Every level the game holds is
## open; [method choose] ignores one it does not. [signal level_changed] tells
## the level shown, on each choice; [method refresh] redraws the selector from
## the game, the owner calls it after each change.

## The level shown changed: the map shows [param level].
signal level_changed(level: int)

## How far the selector sits from the top.
const TOP := 4

var game: Game
var level := 1
var selector := LevelSelector.new()


func _init(game_: Game) -> void:
	super()
	game = game_
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	selector.level_selected.connect(choose)
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override(&"margin_top", TOP)
	margin.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	margin.add_child(selector)
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(margin)
	add_child(column)
	refresh()


## Shows [param next] when the game holds that level.
func choose(next: int) -> void:
	if not game.levels.has(next):
		return
	level = next
	refresh()
	level_changed.emit(level)


## Redraws the selector from the game.
func refresh() -> void:
	# Called once by the base class, before there is a game to show.
	if game == null:
		return
	if not game.levels.has(level):
		level = 1
	var open: Array[int] = []
	for held: int in game.levels:
		open.append(held)
	selector.show_state(level, open)

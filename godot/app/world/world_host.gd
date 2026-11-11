class_name WorldHost
extends Node3D
## The deep sea behind the screens: the player's base, seen from the game
## view. While a menu shows it drifts slowly around the island, out of reach
## of the touches (the ambience); once a game is played the camera is the
## player's again. The 2D screens draw over it.

## How fast the ambience turns around the island, in degrees per second.
const DRIFT := 4.0
## The share of the screen, from the top, the island is framed under: none,
## it sits mid-screen between the title and the entries of the menu.
const HUD := 0.0

var base := BaseScene.new()
var _top := HUD
var _bottom := 0.0
## Whether the camera turns by itself, deaf to the touches.
var drifting := true:
	set = set_drifting


func _init() -> void:
	add_child(base)


func _ready() -> void:
	# Entering the tree gave the camera its touches back.
	set_drifting(drifting)
	get_viewport().size_changed.connect(_frame)
	_frame()


func _process(delta: float) -> void:
	base.camera.rig.goal_yaw += DRIFT * delta


## Lets the camera drift on its own, or gives it back to the player's touches.
func set_drifting(enabled: bool) -> void:
	drifting = enabled
	base.camera.set_process_unhandled_input(not enabled)
	set_process(enabled)


## Shows the base of a game, the buildings [param held] has built, in the
## player's hands.
func show_game(held: Dictionary[BuildingType.Value, Building]) -> void:
	base.show_base(held)


## Shows the ambience of the menus again: the prototype's buildings, the
## island framed under the title.
func show_ambience() -> void:
	base.build(BaseScene.BUILT)
	frame_between(HUD, 0.0)
	set_shown(true)


## Frames the island between the bars of the game screen: the top
## [param top] share of the screen and its bottom [param bottom] share.
func frame_between(top: float, bottom: float) -> void:
	_top = top
	_bottom = bottom
	_frame()


## Shows the world, or hides it and pauses it behind a page that covers it.
func set_shown(shown: bool) -> void:
	visible = shown
	process_mode = Node.PROCESS_MODE_INHERIT if shown else Node.PROCESS_MODE_DISABLED


func _frame() -> void:
	base.frame(_top, _bottom)

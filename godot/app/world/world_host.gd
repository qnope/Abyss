class_name WorldHost
extends Node3D
## The deep sea behind the screens: the player's base, seen from the game
## view. While a menu shows it drifts slowly around the island, out of reach
## of the touches (the ambience); once a game is played the camera is the
## player's again. The 2D screens draw over it.
##
## What it shows is one view at a time ([enum View]): the base, the army's
## parade ground, the map of a level, or nothing behind a page that covers the
## world. The
## ambience (the water, the sky) is the base's and stays on for every view,
## lit as the view is: by the base's light, or by the one of the level the map shows.

## How fast the ambience turns around the island, in degrees per second.
const DRIFT := 4.0
## The share of the screen, from the top, the island is framed under: none,
## it sits mid-screen between the title and the entries of the menu.
const HUD := 0.0

## What the world shows: the base, the parade ground of the army, the map of a
## level, or none.
enum View { BASE, PARADE, MAP, NONE }

var base := BaseScene.new()
var parade := ParadeScene.new()
var map := MapScene.new()
## The view on show.
var view := View.BASE
var _top := HUD
var _bottom := 0.0
## Whether the camera turns by itself, deaf to the touches.
var drifting := true:
	set = set_drifting


func _init() -> void:
	add_child(base)
	add_child(parade)
	add_child(map)
	map.level_shown.connect(_light)
	show_view(View.BASE)


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


## Shows the base of a game in the player's hands: the buildings
## [param held], with the signs of those that can rise now
## ([param upgradable]) and of the plots a prerequisite holds back
## ([param locked]).
func show_game(
	held: Dictionary[BuildingType.Value, Building],
	upgradable: Dictionary[BuildingType.Value, bool] = {},
	locked: Dictionary[BuildingType.Value, bool] = {},
) -> void:
	base.show_base(held, upgradable, locked)


## Shows the ambience of the menus again: the prototype's buildings, the
## island framed under the title.
func show_ambience() -> void:
	base.build(BaseScene.BUILT)
	frame_between(HUD, 0.0)
	show_view(View.BASE)


## Frames the island between the bars of the game screen: the top
## [param top] share of the screen and its bottom [param bottom] share.
func frame_between(top: float, bottom: float) -> void:
	_top = top
	_bottom = bottom
	_frame()


## Shows [param next]: the base, the parade ground or the map, with its camera
## the current one and the other scenes hidden and paused, or none, the whole
## world hidden and paused behind a page that covers it.
func show_view(next: View) -> void:
	view = next
	visible = next != View.NONE
	process_mode = Node.PROCESS_MODE_INHERIT if visible else Node.PROCESS_MODE_DISABLED
	_activate(base, next == View.BASE)
	_activate(parade, next == View.PARADE)
	_activate(map, next == View.MAP)
	_light()
	if next != View.NONE:
		_camera_of(next).current = true


## Lights the water as the view on show: the level of the map, or the base's.
func _light(_level := 0) -> void:
	base.water.set_mood(LightMoods.of_level(map.level) if view == View.MAP else LightMoods.base())


func _camera_of(shown: View) -> Camera3D:
	match shown:
		View.PARADE:
			return parade.camera
		View.MAP:
			return map.camera
	return base.camera


func _activate(scene: Node3D, active: bool) -> void:
	scene.visible = active
	scene.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED


func _frame() -> void:
	base.frame(_top, _bottom)
	parade.frame(_top, _bottom)
	map.frame(_top, _bottom)

class_name GameController
extends RefCounted
## The glue of the game screen: it connects the HUD (UI), the world (3D) and
## the session (the game and its saves), none of which knows the others.
##
## - The tab on show chooses what the world shows: the base on the Base tab;
##   the other tabs cover it with their page until their views are built, and
##   the world is hidden and paused behind them.
## - A change of the game, once saved by the session, redraws the HUD and the
##   buildings standing on the base.
## - The island is framed in the area the HUD leaves clear between its bars.
## - The ways out of the screen are told on: [signal quit_requested] and
##   [signal language_chosen].
##
## The "next turn" button is the next lot's: the HUD tells it, nobody hears
## it yet.

## The player wants to save the game and leave it.
signal quit_requested
## The player picked [param choice] in the settings: `app/` keeps it.
signal language_chosen(choice: LanguageChoice.Value)

var session: GameSession
var hud: GameHud
var world: WorldHost


func _init(session_: GameSession, hud_: GameHud, world_: WorldHost) -> void:
	session = session_
	hud = hud_
	world = world_
	hud.tab_changed.connect(_on_tab_changed)
	hud.quit_requested.connect(quit_requested.emit)
	hud.language_chosen.connect(language_chosen.emit)
	hud.content.item_rect_changed.connect(_frame)
	session.changed.connect(_on_changed)
	_show_base()
	_frame()


## The screen is gone: the world goes back to the menus' ambience.
func close() -> void:
	session.changed.disconnect(_on_changed)
	world.show_ambience()


func _on_changed() -> void:
	hud.refresh()
	_show_base()


func _on_tab_changed(tab: GameTab.Value) -> void:
	world.set_shown(tab == GameTab.Value.BASE)


func _show_base() -> void:
	world.show_game(session.game.human_player().buildings)


## Frames the island between the bars: the share of the screen above the
## clear area and the share below it. Nothing to frame until the screen is
## in the tree: its first layout tells.
func _frame() -> void:
	if not hud.content.is_inside_tree():
		return
	var height := maxf(hud.content.get_viewport_rect().size.y, 1.0)
	var top := hud.content.global_position.y
	var bottom := height - top - hud.content.size.y
	world.frame_between(top / height, maxf(bottom, 0.0) / height)

class_name MapController
extends RefCounted
## The glue of the map tab: the [MapTab] over the world, the map in 3D under
## it, and the sheets a tap opens (lib/presentation/screens/game/
## game_screen_map_actions.dart).
##
## - The level on show is the tab's own ([MapTab.level], not saved): the map
##   draws it from the game ([MapStates]), the cells seen as fog lifted, the
##   scouts on their way as tokens.
## - A tap on a cell of the map goes to the [member router], which opens the
##   sheet of the cell. What a sheet does goes through the session's actions,
##   which save and redraw: the map is drawn again on each change of the game.
## - Another lot adds its sheet with `router.register(kind, handler)` (a lair,
##   a post, the volcano, a rival's base); the status bars and the guide show a
##   level with `show_level`.
## - The tab is over the world only on the Map tab, and the map is drawn only
##   while it is on show.

var tab: MapTab
var router: CellRouter
var session: GameSession
var _hud: GameHud
var _world: WorldHost


func _init(session_: GameSession, hud: GameHud, world: WorldHost, modals: ModalLayer) -> void:
	session = session_
	_hud = hud
	_world = world
	tab = MapTab.new(session.game, session.actions.guide)
	tab.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.content.add_child(tab)
	router = CellRouter.new(session.actions, modals)
	tab.level_changed.connect(_draw)
	session.changed.connect(_on_changed)
	hud.tab_changed.connect(_on_tab_changed)
	hud.map_requested.connect(_open)
	world.map.cell_tapped.connect(router.route)
	_on_tab_changed(hud.tab)


## The screen is gone: nothing is listened to any more, the tab leaves.
func close() -> void:
	tab.level_changed.disconnect(_draw)
	session.changed.disconnect(_on_changed)
	_hud.tab_changed.disconnect(_on_tab_changed)
	_hud.map_requested.disconnect(_open)
	_world.map.cell_tapped.disconnect(router.route)
	_hud.content.remove_child(tab)
	tab.free()
	_world.map.forget()


## Shows [param level] on the map, if the game holds it.
func show_level(level: int) -> void:
	tab.choose(level)


## Plays [param attack] on the map, calling [param then] once it is over (at once
## when the map is not on show).
func strike(attack: MapStrike, then: Callable) -> void:
	_world.map.strike(attack, then)


## Plays [param attack], attackers besieging a place of the level on show, calling
## [param then] once it is over: what the turn story will tell of the raids and
## the waves that struck during the turn.
func siege(attack: MapSiege, then: Callable) -> void:
	_world.map.siege(attack, then)


## A strip points at [param level]: the Map tab shows it.
func _open(level: int) -> void:
	show_level(level)
	_hud.show_tab(GameTab.Value.MAP)


func _on_changed() -> void:
	tab.refresh()
	_draw(tab.level)


func _on_tab_changed(shown: GameTab.Value) -> void:
	tab.visible = shown == GameTab.Value.MAP
	_draw(tab.level)


func _draw(level: int) -> void:
	if tab.visible:
		_world.map.show_level(MapStates.of(session.game, level))

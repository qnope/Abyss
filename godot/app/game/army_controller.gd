class_name ArmyController
extends RefCounted
## The glue of the army tab: the [ArmyTab] over the world, the parade ground
## in 3D under it, and the sheets a tap opens.
##
## - The tab's roster (the army at the place shown) is written as the squads
##   of the parade ([ParadeStates]) and the barracks beside them.
## - A change of the game, once saved by the session, redraws the tab and the
##   parade.
## - A tap on a squad opens the sheet of its unit, with its recruitment,
##   which goes through the session's actions: they save and redraw. A tap on
##   the barracks opens the sheet of the building.
## - The tab is over the world only on the Army tab; the banners of the base
##   float only on the Base tab.

var tab: ArmyTab
var session: GameSession
var _hud: GameHud
var _world: WorldHost
var _modals: ModalLayer


func _init(session_: GameSession, hud: GameHud, world: WorldHost, modals: ModalLayer) -> void:
	session = session_
	_hud = hud
	_world = world
	_modals = modals
	tab = ArmyTab.new(session.game)
	tab.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.content.add_child(tab)
	tab.changed.connect(_show_army)
	session.changed.connect(_on_changed)
	hud.tab_changed.connect(_on_tab_changed)
	world.parade.squad_tapped.connect(_open_unit)
	world.parade.barracks_tapped.connect(_open_barracks)
	_on_tab_changed(hud.tab)
	_show_army(tab.roster)


## The screen is gone: nothing is listened to any more, the tab leaves.
func close() -> void:
	tab.changed.disconnect(_show_army)
	session.changed.disconnect(_on_changed)
	_hud.tab_changed.disconnect(_on_tab_changed)
	_world.parade.squad_tapped.disconnect(_open_unit)
	_world.parade.barracks_tapped.disconnect(_open_barracks)
	_hud.content.remove_child(tab)
	tab.free()


func _on_changed() -> void:
	tab.refresh()


func _show_army(roster: ArmyRoster) -> void:
	_world.parade.show_army(ParadeStates.squads(roster), ParadeStates.barracks(session.game))


func _on_tab_changed(shown: GameTab.Value) -> void:
	tab.visible = shown == GameTab.Value.ARMY
	_hud.banners.visible = shown == GameTab.Value.BASE


func _open_unit(type: UnitType.Value) -> void:
	_modals.open(UnitSheet.new(session.actions, type, tab.count_of(type)))


func _open_barracks() -> void:
	_hud.open_building(BuildingType.Value.BARRACKS)

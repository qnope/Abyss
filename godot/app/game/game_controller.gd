class_name GameController
extends RefCounted
## The glue of the game screen: it connects the HUD (UI), the world (3D) and
## the session (the game and its saves), none of which knows the others.
##
## - The tab on show chooses what the world shows ([TabViews]): the base on
##   the Base tab, the army's parade ground on the Army tab ([ArmyController]),
##   the map of the levels on the Map tab ([MapController]), whose lairs open
##   the fights ([FightController]), its posts ([PostController]), its volcano ([KernelController]) and
##   the rival factions ([FactionController]), and the guide's rings
##   ([GuideController]); the other tabs
##   cover it with their page until their views are built, and the world is
##   hidden and paused behind them.
## - A change of the game, once saved by the session, redraws the HUD and the
##   base: its buildings and the signs over its pads.
## - A tap on a pad of the base, built or not, opens the sheet of its
##   building; the sheet's upgrade goes through the session's actions, which
##   save and redraw.
## - The island is framed in the area the HUD leaves clear between its bars.
## - The "next turn" button starts the [EndTurnFlow]: the question, the turn
##   (saved and redrawn by the session), the summary, and once the pages are
##   seen the screen is redrawn again. A game lost is told with
##   [signal defeated], for `app/` to show the defeat screen.
## - A kernel raised to the last level (the actions tell [signal
##   GameActions.victory_reached]) opens the victory screen over the game:
##   "continue" goes on in free play, "menu" leaves as saving and quitting does.
## - The ways out of the screen are told on: [signal quit_requested] and
##   [signal language_chosen].

## The turn that just ended lost the game.
signal defeated
## The player wants to save the game and leave it.
signal quit_requested
## The player picked [param choice] in the settings: `app/` keeps it.
signal language_chosen(choice: LanguageChoice.Value)

var session: GameSession
var hud: GameHud
var world: WorldHost
var end_turn: EndTurnFlow
var army: ArmyController
var map: MapController
var fight: FightController
var post: PostController
var kernel: KernelController
var faction: FactionController
var guide: GuideController
var _modals: ModalLayer


func _init(session_: GameSession, hud_: GameHud, world_: WorldHost, modals: ModalLayer) -> void:
	session = session_
	hud = hud_
	world = world_
	_modals = modals
	end_turn = EndTurnFlow.new(session.actions, modals)
	hud.end_turn_requested.connect(end_turn.request)
	end_turn.finished.connect(_on_changed)
	end_turn.defeated.connect(defeated.emit)
	session.actions.victory_reached.connect(_on_victory)
	hud.tab_changed.connect(_on_tab_changed)
	hud.quit_requested.connect(quit_requested.emit)
	hud.language_chosen.connect(language_chosen.emit)
	hud.content.item_rect_changed.connect(_frame)
	world.base.building_tapped.connect(hud.open_building)
	army = ArmyController.new(session, hud, world, modals)
	map = MapController.new(session, hud, world, modals)
	fight = FightController.new(session.actions, map.router, modals)
	post = PostController.new(session.actions, map.router, modals, map.show_level)
	kernel = KernelController.new(session.actions, map.router, modals)
	faction = FactionController.new(session.actions, map.router, modals, post, kernel)
	guide = GuideController.new(session.actions.guide, world)
	session.changed.connect(_on_changed)
	_show_base()
	_frame()


## The screen is gone: the world goes back to the menus' ambience.
func close() -> void:
	army.close()
	map.close()
	guide.close()
	session.changed.disconnect(_on_changed)
	session.actions.victory_reached.disconnect(_on_victory)
	world.base.building_tapped.disconnect(hud.open_building)
	world.show_ambience()


func _on_changed() -> void:
	hud.refresh()
	_show_base()


## The game is won: the victory screen over the game, until the player picks
## what follows.
func _on_victory() -> void:
	var screen := GameOverScreens.victory(session.game)
	screen.continue_requested.connect(_continue_in_free_play.bind(screen))
	screen.menu_requested.connect(_leave_for_menu.bind(screen))
	_modals.open(screen)


func _continue_in_free_play(screen: GameOverScreen) -> void:
	screen.close()
	session.actions.continue_in_free_play()


func _leave_for_menu(screen: GameOverScreen) -> void:
	screen.close()
	quit_requested.emit()


func _on_tab_changed(tab: GameTab.Value) -> void:
	world.show_view(TabViews.of(tab))


func _show_base() -> void:
	var game := session.game
	world.show_game(game.human_player().buildings, BaseReadiness.upgradable(game), BaseReadiness.locked(game))


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

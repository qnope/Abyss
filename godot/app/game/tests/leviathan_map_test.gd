extends UiTestCase
## test/presentation/widgets/common/game_status_bars_test.dart (onOpenMap): a touch
## on the red strip of the guardians shows the level of the Faille they strike,
## on the Map tab.

var _folder: TempFolder
var _war: PostWar
var _world: WorldHost
var _hud: GameHud
var _controller: GameController


func before_each() -> void:
	_folder = TempFolder.new()
	add_cleanup(_folder.remove)
	_war = LeviathanScene.of()
	LeviathanScene.play_until(_war, LeviathanScene.strike_turn(_war))
	var session := GameSession.new(_war.game, GameRepository.new(_folder.path.path_join("saves")))
	_world = WorldHost.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_world)
	add_cleanup(_world.free)
	_hud = GameHud.new(session.actions, LanguageChoice.Value.FRENCH, modals())
	mount(_hud)
	_controller = GameController.new(session, _hud, _world, modals())
	add_cleanup(func() -> void: _controller = null)


func test_the_strip_of_the_guardians_is_a_button_that_opens_the_map() -> void:
	assert_eq(_hud.tab, GameTab.Value.BASE)
	var strips: Array[Control] = _hud.status_bars.bars().filter(func(bar: Control) -> bool: return bar is LeviathanStatusBar)
	var strip: LeviathanStatusBar = strips[0]
	assert_true(strip.visible)
	press(strip.banner.tap)
	assert_eq(_hud.tab, GameTab.Value.MAP)
	assert_eq(_controller.map.tab.level, _war.level)


func test_the_level_of_the_faille_is_the_one_shown() -> void:
	_controller.map.tab.choose(2)
	_hud.map_requested.emit(1)
	assert_eq(_controller.map.tab.level, 1)
	assert_eq(_hud.tab, GameTab.Value.MAP)


func test_closing_the_screen_lets_go_of_the_strip() -> void:
	_controller.close()
	_hud.map_requested.emit(2)
	assert_eq(_hud.tab, GameTab.Value.BASE)

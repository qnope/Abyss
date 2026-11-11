extends UiTestCase
## The tutorial through the game screen (game_screen_guide_test.dart): the
## first advice with its bubble and its ring, the halos that follow what it
## points at, and the guide that goes quiet.

const Tab := GameTab.Value

var _folder: TempFolder
var _game: Game
var _session: GameSession
var _world: WorldHost
var _hud: GameHud
var _controller: GameController


func _screen(game: Game) -> void:
	_folder = TempFolder.new()
	add_cleanup(_folder.remove)
	_game = game
	_session = GameSession.new(_game, GameRepository.new(_folder.path.path_join("saves")))
	_world = WorldHost.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_world)
	add_cleanup(_world.free)
	_hud = GameHud.new(_session.actions, LanguageChoice.Value.FRENCH, modals())
	mount(_hud)
	_controller = GameController.new(_session, _hud, _world, modals())
	add_cleanup(func() -> void: _controller = null)


func _bubble() -> GuideBubble:
	return find_type("GuideBubble")[0] as GuideBubble


func test_a_tutorial_game_shows_the_first_advice_and_rings_the_headquarters() -> void:
	_screen(GuideSamples.guide_game(ObjectiveId.Value.HQ_LEVEL_1))
	assert_true(_bubble().visible)
	assert_not_null(find_text(GuideMessageTexts.text(_session.actions.guide.advice.message)))
	assert_true(_world.base.guide.visible)
	assert_eq(_world.base.guide.caption.text, BuildingTexts.display_name(BuildingType.Value.HEADQUARTERS))
	assert_false(_hud.turn_bar.halo.active)
	assert_false(_hud.tab_bar.halo_of(Tab.MAP).active)


func test_following_the_advice_moves_the_halo_to_the_turn_button() -> void:
	_screen(GuideSamples.guide_game(ObjectiveId.Value.HQ_LEVEL_1))
	_game.human_player().buildings[BuildingType.Value.HEADQUARTERS].level = 1
	_session.actions.guide.refresh()
	assert_true(_hud.turn_bar.halo.active)
	assert_false(_world.base.guide.visible, "the pad is no longer the target")
	assert_not_null(find_text("Bravo, c'est fait ! Termine le tour pour valider l'objectif et toucher ta récompense."))


func test_the_advice_to_explore_lights_the_map_tab() -> void:
	_screen(GuideSamples.guide_game(ObjectiveId.Value.EXPLORE))
	assert_true(_hud.tab_bar.halo_of(Tab.MAP).active)
	press("Carte")
	assert_false(_hud.tab_bar.halo_of(Tab.MAP).active, "already open")


func test_got_it_hides_the_bubble_and_keeps_the_ring() -> void:
	_screen(GuideSamples.guide_game(ObjectiveId.Value.HQ_LEVEL_1))
	press("Compris")
	assert_false(_bubble().visible)
	assert_true(_world.base.guide.visible)


func test_the_guide_is_quiet_when_the_tutorial_is_off() -> void:
	_screen(GuideSamples.guide_game(ObjectiveId.Value.HQ_LEVEL_1, false))
	assert_false(_bubble().visible)
	assert_false(_world.base.guide.visible)
	assert_false(_hud.turn_bar.halo.active)
	assert_null(find_text("Compris"))


func test_switching_the_guide_off_puts_everything_away() -> void:
	_screen(GuideSamples.guide_game(ObjectiveId.Value.HQ_LEVEL_1))
	_session.actions.set_guide_enabled(false)
	assert_false(_bubble().visible)
	assert_false(_world.base.guide.visible)


func test_the_bubble_and_the_banner_speak_the_three_languages() -> void:
	_screen(GuideSamples.guide_game(ObjectiveId.Value.HQ_LEVEL_1))
	for language: String in ["en", "es", "fr"]:
		use_language(language)
		assert_no_raw_keys(_hud)
	use_language("en")
	assert_not_null(find_text("Got it"))

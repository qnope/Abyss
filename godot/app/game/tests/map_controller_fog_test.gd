extends UiTestCase
## The map tab and the fog its scouts lift: the cells a scout has seen since the
## map was last drawn lift their fog while the map shows.

var _folder: TempFolder
var _session: GameSession
var _world: WorldHost
var _controller: GameController
var _game: Game
var _human: Player


func before_each() -> void:
	_folder = TempFolder.new()
	add_cleanup(_folder.remove)
	_game = GameFactory.new_game("Nemo", 1, Difficulty.Value.NORMAL, false, 2, null, "me")
	_human = _game.human_player()
	_session = GameSession.new(_game, GameRepository.new(_folder.path.path_join("saves")))
	_world = WorldHost.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_world)
	add_cleanup(_world.free)
	var hud := GameHud.new(_session.actions, LanguageChoice.Value.FRENCH, modals())
	mount(hud)
	_controller = GameController.new(_session, hud, _world, modals())
	add_cleanup(func() -> void: _controller = null)
	_world.frame_between(0.15, 0.15)


## A cell of the first level next to the cells seen, not seen itself.
func _hidden_next_to_the_seen() -> void:
	var seen := _human.revealed_cells_set_on_level(1)
	var map := _game.levels[1]
	for y in map.height:
		for x in map.width:
			if not seen.has(Vector2i(x, y)) and CellEligibilityChecker.is_eligible(map, _human, x, y):
				_human.add_revealed_cell(1, GridPosition.new(x, y))
				return


func test_the_fog_lifts_from_the_cells_a_scout_sees_while_the_map_shows() -> void:
	press("Carte")
	var effects := _world.map.effects
	assert_false(effects.is_playing(), "the level opens with its fog as it is")
	_hidden_next_to_the_seen()
	_session.actions.mark(func(_g: Game) -> void: pass)
	assert_true(effects.current is FogLift)
	assert_true((effects.current as FogLift).clouds.size() > 0)


func test_closing_the_screen_forgets_what_the_levels_showed() -> void:
	press("Carte")
	_controller.map.close()
	_hidden_next_to_the_seen()
	_world.map.show_level(MapStates.of(_game, 1))
	assert_false(_world.map.effects.is_playing())

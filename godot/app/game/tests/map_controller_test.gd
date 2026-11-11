extends UiTestCase
## The map tab through the game screen (game_screen_map_test.dart,
## game_screen_map_actions_flow_test.dart): the Map tab shows the map in 3D,
## the level selector changes the level, a tap on a cell opens its sheet, and
## what the sheet does changes the game, saves it and redraws the map.

const Scout := UnitType.Value.SCOUT

var _folder: TempFolder
var _repository: GameRepository
var _session: GameSession
var _world: WorldHost
var _hud: GameHud
var _controller: GameController
var _game: Game
var _human: Player


func before_each() -> void:
	_folder = TempFolder.new()
	add_cleanup(_folder.remove)
	_repository = GameRepository.new(_folder.path.path_join("saves"))
	_game = GameFactory.new_game("Nemo", 1, Difficulty.Value.NORMAL, false, 2, null, "me")
	_human = _game.human_player()
	_human.units_per_level[1] = DomainSamples.units({Scout: 3})
	_session = GameSession.new(_game, _repository)
	_world = WorldHost.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_world)
	add_cleanup(_world.free)
	_hud = GameHud.new(_session.actions, LanguageChoice.Value.FRENCH, modals())
	mount(_hud)
	_controller = GameController.new(_session, _hud, _world, modals())
	add_cleanup(func() -> void: _controller = null)
	_world.frame_between(0.15, 0.15)


## A cell of the first level next to the cells seen, not seen itself.
func _hidden_next_to_the_seen() -> Vector2i:
	var seen := _human.revealed_cells_set_on_level(1)
	var map := _game.levels[1]
	for y in map.height:
		for x in map.width:
			if not seen.has(Vector2i(x, y)) and CellEligibilityChecker.is_eligible(map, _human, x, y):
				return Vector2i(x, y)
	return Vector2i(-1, -1)


func _tap(x: int, y: int, level := 1) -> void:
	_world.map.cell_tapped.emit(level, x, y)


func _saved() -> Game:
	return _repository.load_all().games[0]


func test_the_map_tab_shows_the_map_and_its_selector_over_it() -> void:
	assert_false(_controller.map.tab.visible)
	assert_eq(_world.map.level, 0, "nothing is drawn until the map is on show")
	press("Carte")
	assert_eq(_world.view, WorldHost.View.MAP)
	assert_true(_world.map.camera.current)
	assert_true(_controller.map.tab.visible)
	assert_eq(_world.map.level, 1)
	assert_eq(_world.map.state.base, Vector2i(_human.base_x, _human.base_y))
	press("Base")
	assert_false(_controller.map.tab.visible)


func test_the_selector_changes_the_level_the_map_shows() -> void:
	press("Carte")
	press("Niv. 2 : Profondeurs")
	assert_eq(_world.map.level, 2)
	assert_null(_world.map.state.base)
	press("Niv. 3 : Noyau")
	assert_eq(_world.map.level, 3)
	press("Niv. 1 : Surface")
	assert_eq(_world.map.level, 1)


func test_another_part_of_the_game_shows_a_level_with_show_level() -> void:
	press("Carte")
	_controller.map.show_level(2)
	assert_eq(_world.map.level, 2)
	_controller.map.show_level(7)
	assert_eq(_world.map.level, 2, "a level the game does not hold is ignored")


func test_a_tap_on_a_hidden_cell_sends_a_scout_and_saves() -> void:
	press("Carte")
	var at := _hidden_next_to_the_seen()
	_tap(at.x, at.y)
	assert_not_null(find_text("Explorer (%d, %d)" % [at.x, at.y]))
	press("Envoyer")
	assert_null(current_modal())
	assert_eq(_human.pending_explorations.size(), 1)
	assert_eq(_human.units_on_level(1)[Scout].count, 2)
	var saved := _saved().human_player()
	assert_eq(saved.pending_explorations.size(), 1)
	assert_eq(saved.pending_explorations[0].target.key(), at)
	assert_true(_world.map.scouts.tokens.has(at), "the scout is seen on its way")
	assert_eq(_world.map.state.pending.keys(), [at] as Array[Vector2i])


func test_a_tap_on_a_treasure_collects_it_and_tells_what_was_found() -> void:
	press("Carte")
	var at := Vector2i(_human.base_x + 1, _human.base_y)
	_game.levels[1].set_cell(at.x, at.y, MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.RESOURCE_BONUS))
	var before := _human.resources[ResourceType.Value.ALGAE].amount
	_tap(at.x, at.y)
	assert_not_null(find_text("Trésor (%d, %d)" % [at.x, at.y]))
	press("Collecter le trésor")
	assert_not_null(find_text("Trésor collecté !"))
	assert_true(_human.resources[ResourceType.Value.ALGAE].amount != before)
	assert_true(_saved().levels[1].cell_at(at.x, at.y).is_collected())
	press("OK")
	assert_null(current_modal())
	_tap(at.x, at.y)
	assert_not_null(find_text("Déjà visité"))


func test_a_tap_on_the_base_opens_its_card() -> void:
	press("Carte")
	_tap(_human.base_x, _human.base_y)
	assert_not_null(find_text("Votre base"))


func test_what_another_lot_registers_opens_its_kind() -> void:
	var routes: Array[CellRoute] = []
	_controller.map.router.register(CellRoute.Kind.HOME, routes.append)
	_tap(_human.base_x, _human.base_y)
	assert_eq(routes.size(), 1)
	assert_null(current_modal())


func test_the_selector_follows_the_game() -> void:
	press("Carte")
	_game.levels.erase(3)
	_session.actions.mark(func(_g: Game) -> void: pass)
	assert_true(_controller.map.tab.selector.chips[3].disabled)


func test_closing_the_screen_lets_go_of_the_map() -> void:
	var tab := _controller.map.tab
	_controller.map.close()
	assert_false(is_instance_valid(tab))
	_tap(_human.base_x, _human.base_y)
	assert_null(current_modal())

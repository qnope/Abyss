extends UiTestCase
## The research through the game screen: the Tech tab shows the tree over the
## hidden world, a touch opens the sheet, unlocking or researching changes the
## game, saves it and redraws the tree (game_screen_tech_actions_test.dart).

const Branch := TechBranch.Value
const Type := BuildingType.Value

var _folder: TempFolder
var _game: Game
var _session: GameSession
var _world: WorldHost
var _hud: GameHud
var _controller: GameController


func before_each() -> void:
	_folder = TempFolder.new()
	add_cleanup(_folder.remove)
	_game = GameFactory.new_single_player("Nemo", 1)
	_game.human_player().buildings[Type.LABORATORY].level = 2
	for resource: GameResource in _game.human_player().resources.values():
		resource.amount = resource.max_storage
	_session = GameSession.new(_game, GameRepository.new(_folder.path.path_join("saves")))
	_world = WorldHost.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_world)
	add_cleanup(_world.free)
	_hud = GameHud.new(_session.actions, LanguageChoice.Value.FRENCH, modals())
	mount(_hud)
	_controller = GameController.new(_session, _hud, _world, modals())
	add_cleanup(func() -> void: _controller = null)
	press("Tech")


func _saved() -> Game:
	return _session.repository.load_all().games[0]


func test_the_tab_shows_the_tree_and_hides_the_world() -> void:
	assert_true(_hud.tech_tab.visible)
	assert_false(_world.visible)
	assert_not_null(find_text("Explorateur", _hud.tech_tab))
	assert_null(find_text("Bientôt disponible", _hud.content))
	assert_no_raw_keys(_hud.content)


func test_unlocking_a_branch_changes_the_game_saves_it_and_redraws_the_tree() -> void:
	press(_hud.tech_tab.tree.columns[Branch.MILITARY].medallion.tap_button)
	press("Débloquer")
	var human := _game.human_player()
	assert_true(human.tech_branches[Branch.MILITARY].unlocked)
	assert_null(current_modal())
	assert_true(_saved().human_player().tech_branches[Branch.MILITARY].unlocked, "saved")
	var tree := _hud.tech_tab.tree
	assert_true(tree.columns[Branch.MILITARY].medallion.unlocked, "redrawn")
	assert_eq(tree.node_at(Branch.MILITARY, 1).state, TechNodeState.Value.ACCESSIBLE)
	var ore := _hud.resource_bar.items[ResourceType.Value.ORE]
	assert_eq(ore.amount_label.text, str(human.resources[ResourceType.Value.ORE].amount), "the stock is paid")


func test_a_change_on_another_tab_redraws_the_tree_once_the_tech_tab_shows() -> void:
	press("Base")
	var before := _hud.tech_tab.tree.get_instance_id()
	_session.actions.mark(func(game: Game) -> void:
		game.human_player().tech_branches[Branch.EXPLORER].unlocked = true)
	assert_eq(_hud.tech_tab.tree.get_instance_id(), before, "no tree is built behind the base")
	press("Tech")
	assert_true(_hud.tech_tab.tree.columns[Branch.EXPLORER].medallion.unlocked)


func test_researching_a_node_spends_the_turns_research_until_the_next_turn() -> void:
	_game.human_player().tech_branches[Branch.EXPLORER].unlocked = true
	_session.actions.mark(func(_g: Game) -> void: pass)
	press(_hud.tech_tab.tree.node_at(Branch.EXPLORER, 1).tap_button)
	press("Rechercher")
	assert_eq(_saved().human_player().tech_branches[Branch.EXPLORER].research_level, 1)
	press(_hud.tech_tab.tree.node_at(Branch.EXPLORER, 2, TechOption.Value.B).tap_button)
	assert_not_null(find_text("Une recherche par tour : attends le prochain tour", current_modal()))
	assert_true(_hud.tech_tab.tree.node_at(Branch.EXPLORER, 1).state == TechNodeState.Value.RESEARCHED)


func test_a_choice_is_kept_in_the_save() -> void:
	var state := _game.human_player().tech_branches[Branch.MILITARY]
	state.unlocked = true
	state.research_level = 1
	_session.actions.mark(func(_g: Game) -> void: pass)
	var sheet_node := _hud.tech_tab.tree.node_at(Branch.MILITARY, 2, TechOption.Value.B)
	press(sheet_node.tap_button)
	press((current_modal() as TechTargetSheet).panel.choice_row.cards[TechOption.Value.B].choose_button)
	assert_eq(_saved().human_player().tech_branches[Branch.MILITARY].option_at(2), TechOption.Value.B)
	assert_eq(_hud.tech_tab.tree.node_at(Branch.MILITARY, 2, TechOption.Value.A).state, TechNodeState.Value.DISCARDED)


func test_a_refusal_changes_nothing_and_saves_nothing() -> void:
	press(_hud.tech_tab.tree.columns[Branch.MILITARY].medallion.tap_button)
	_game.human_player().buildings[Type.LABORATORY].level = 0
	press("Débloquer")
	assert_false(_game.human_player().tech_branches[Branch.MILITARY].unlocked)
	assert_not_null(find_text(ActionFailureTexts.message(ActionFailure.Value.LABORATORY_REQUIRED), current_modal()))
	assert_eq(_session.repository.load_all().games.size(), 0)

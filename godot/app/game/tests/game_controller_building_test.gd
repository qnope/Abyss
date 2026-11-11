extends UiTestCase
## The buildings through the game screen: a tap on a pad opens the sheet of
## its building, raising it changes the game, saves it and redraws the base
## (game_screen_actions_test.dart).

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
	_levels({Type.HEADQUARTERS: 1})
	_session = GameSession.new(_game, GameRepository.new(_folder.path.path_join("saves")))
	_world = WorldHost.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_world)
	add_cleanup(_world.free)
	_hud = GameHud.new(_session.actions, LanguageChoice.Value.FRENCH, modals())
	mount(_hud)
	_controller = GameController.new(_session, _hud, _world, modals())
	add_cleanup(func() -> void: _controller = null)


func test_a_tap_on_a_pad_opens_the_sheet_of_its_building() -> void:
	_tap(Type.HEADQUARTERS)
	var sheet := current_modal() as BuildingSheet
	assert_not_null(sheet)
	assert_eq(sheet.type, Type.HEADQUARTERS)


func test_a_tap_on_an_empty_pad_opens_the_sheet_to_build() -> void:
	_tap(Type.LABORATORY)
	assert_not_null(find_text("Laboratoire", current_modal()))
	assert_not_null(find_text("Non construit", current_modal()))


func test_raising_a_building_changes_the_game_saves_it_and_redraws_the_base() -> void:
	_fill_stores()
	_session.actions.mark(func(_g: Game) -> void: pass)
	_tap(Type.HEADQUARTERS)
	press("Améliorer")
	assert_eq(_game.human_player().buildings[Type.HEADQUARTERS].level, 2)
	assert_null(current_modal())
	var saved := _session.repository.load_all().games
	assert_eq(saved.size(), 1)
	assert_eq(saved[0].human_player().buildings[Type.HEADQUARTERS].level, 2)
	var coral := _game.human_player().resources[ResourceType.Value.CORAL]
	assert_true(coral.amount < coral.max_storage, "the cost is paid")
	assert_eq(_hud.resource_bar.items[ResourceType.Value.CORAL].amount_label.text, str(coral.amount))


func test_a_refusal_changes_nothing_and_saves_nothing() -> void:
	_fill_stores()
	_tap(Type.HEADQUARTERS)
	_game.human_player().worksite.upgrades = 1
	press("Améliorer")
	assert_eq(_game.human_player().buildings[Type.HEADQUARTERS].level, 1)
	assert_not_null(current_modal())
	assert_eq(_session.repository.load_all().games.size(), 0)


func test_the_pads_are_signed_by_what_they_can_do() -> void:
	_fill_stores()
	_session.actions.mark(func(_g: Game) -> void: pass)
	assert_eq(_marks(PadMark.Kind.UPGRADE), 1, "the headquarters can rise")
	assert_true(_marks(PadMark.Kind.BUILD) >= 1, "plots can be built on")
	assert_true(_marks(PadMark.Kind.LOCKED) >= 1, "some are held back")


func test_the_rampart_follows_the_citadel() -> void:
	assert_eq(_world.base.rampart_tier, 0)
	_levels({Type.HEADQUARTERS: 5, Type.CORAL_CITADEL: 3})
	_session.actions.mark(func(_g: Game) -> void: pass)
	assert_eq(_world.base.rampart_tier, 2)


func _tap(type: BuildingType.Value) -> void:
	var base := _world.base
	var pad := base.pads.origin_of(BaseBuildings.pad_of(type)) + Vector3.UP * 0.5
	base.camera.tapped.emit(base.camera.unproject_position(pad))


func _levels(levels: Dictionary[BuildingType.Value, int]) -> void:
	for type: BuildingType.Value in levels:
		_game.human_player().buildings[type].level = levels[type]


func _fill_stores() -> void:
	for resource: GameResource in _game.human_player().resources.values():
		resource.amount = resource.max_storage


func _marks(kind: PadMark.Kind) -> int:
	var count := 0
	for mark: Node in _world.base.marks.get_children():
		if mark is PadMark and (mark as PadMark).kind == kind:
			count += 1
	return count

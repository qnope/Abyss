extends UnitTestCase
## The army tab through the game screen (game_screen_army_test.dart): the
## Army tab shows the parade ground, a tap on a squad opens its sheet,
## recruiting changes the game, saves it and redraws the parade.

var _folder: TempFolder
var _session: GameSession
var _world: WorldHost
var _hud: GameHud
var _controller: GameController


func before_each() -> void:
	super()
	_folder = TempFolder.new()
	add_cleanup(_folder.remove)
	_session = GameSession.new(game, GameRepository.new(_folder.path.path_join("saves")))
	_world = WorldHost.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_world)
	add_cleanup(_world.free)
	_hud = GameHud.new(_session.actions, LanguageChoice.Value.FRENCH, modals())
	mount(_hud)
	_controller = GameController.new(_session, _hud, _world, modals())
	add_cleanup(func() -> void: _controller = null)
	# Nothing is laid out in a frame: the camera frames what a screen would.
	_world.frame_between(0.15, 0.15)


func _squad(type: UnitType.Value) -> Squad:
	return _world.parade.squads[type]


func _tap(type: UnitType.Value) -> void:
	var parade := _world.parade
	parade.camera.tapped.emit(parade.camera.unproject_position(_squad(type).global_position + Vector3.UP * 0.5))


func _signs(type: UnitType.Value) -> Array[PadMark.Kind]:
	var kinds: Array[PadMark.Kind] = []
	for mark: Node in _squad(type).marks.get_children():
		kinds.append((mark as PadMark).kind)
	return kinds


func test_the_army_tab_shows_the_parade_ground_and_its_bar_over_it() -> void:
	assert_false(_controller.army.tab.visible)
	assert_true(_hud.banners.visible)
	press("Armée")
	assert_eq(_world.view, WorldHost.View.PARADE)
	assert_true(_world.parade.camera.current)
	assert_true(_controller.army.tab.visible)
	assert_false(_hud.banners.visible)
	assert_false(_hud.page.visible)
	press("Base")
	assert_eq(_world.view, WorldHost.View.BASE)
	assert_false(_controller.army.tab.visible)
	assert_true(_hud.banners.visible)


func test_the_squads_stand_as_the_army_serves_with_a_plus_where_it_recruits() -> void:
	game.human_player().units_per_level[1] = DomainSamples.units({Type.SCOUT: 3})
	_session.actions.mark(func(_g: Game) -> void: pass)
	assert_eq(_squad(Type.SCOUT).state.count, 3)
	assert_eq(_squad(Type.SCOUT).plaque.text, "3\n" + UnitArmyTexts.plaque_name(Type.SCOUT, 3))
	assert_eq(_signs(Type.SCOUT), [PadMark.Kind.BUILD] as Array[PadMark.Kind])
	assert_true(_squad(Type.ABYSS_ADMIRAL).state.locked)
	assert_eq(_signs(Type.ABYSS_ADMIRAL), [PadMark.Kind.LOCKED] as Array[PadMark.Kind])


func test_a_place_of_the_bar_stands_only_its_units() -> void:
	human.units_per_level[1] = DomainSamples.units({Type.SCOUT: 3})
	human.units_per_level[2] = DomainSamples.units({Type.HARPOONIST: 2})
	_session.actions.mark(func(_g: Game) -> void: pass)
	assert_eq(_squad(Type.HARPOONIST).state.count, 2)
	_controller.army.tab.choose(2)
	assert_eq(_squad(Type.SCOUT).state.count, 0)
	assert_eq(_squad(Type.HARPOONIST).state.count, 2)
	assert_eq(_signs(Type.SCOUT), [] as Array[PadMark.Kind], "recruits do not arrive there")
	_controller.army.tab.choose(ArmyPlaces.ALL)
	assert_eq(_squad(Type.SCOUT).state.count, 3)


func test_a_tap_on_a_squad_opens_the_sheet_of_its_unit() -> void:
	human.units_per_level[1] = DomainSamples.units({Type.SCOUT: 3})
	_session.actions.mark(func(_g: Game) -> void: pass)
	_tap(Type.SCOUT)
	var sheet := current_modal() as UnitSheet
	assert_not_null(sheet)
	assert_eq(sheet.type, Type.SCOUT)
	assert_eq(sheet.count, 3)


func test_a_tap_on_the_barracks_opens_its_sheet() -> void:
	var parade := _world.parade
	parade.camera.tapped.emit(parade.camera.unproject_position(parade.barracks.global_position + Vector3.UP * 0.5))
	var sheet := current_modal() as BuildingSheet
	assert_not_null(sheet)
	assert_eq(sheet.type, BuildingType.Value.BARRACKS)


func test_recruiting_changes_the_game_saves_it_and_redraws_the_parade() -> void:
	_tap(Type.SCOUT)
	slider_in(current_modal()).value = 4
	press("Recruter")
	assert_eq(units_at(Type.SCOUT), 4)
	assert_null(current_modal())
	assert_eq(_squad(Type.SCOUT).state.count, 4)
	assert_eq(_squad(Type.SCOUT).figures.get_child_count(), SquadSize.of(4))
	var saved := _session.repository.load_all().games
	assert_eq(saved.size(), 1)
	assert_eq(saved[0].human_player().units_on_level(1)[Type.SCOUT].count, 4)


func test_a_refusal_is_told_in_the_sheet_and_changes_nothing() -> void:
	_tap(Type.SCOUT)
	slider_in(current_modal()).value = 2
	human.recruited_unit_types.append(Type.SCOUT)
	press("Recruter")
	assert_not_null(find_text("Recrutement déjà effectué ce tour", current_modal()))
	assert_eq(units_at(Type.SCOUT), 0)
	assert_eq(_session.repository.load_all().games.size(), 0)


func test_a_squad_with_nothing_to_recruit_with_has_no_plus() -> void:
	human.resources[ResourceType.Value.ALGAE].amount = 0
	_session.actions.mark(func(_g: Game) -> void: pass)
	assert_eq(_signs(Type.SCOUT), [] as Array[PadMark.Kind])


func test_the_plaques_follow_the_language() -> void:
	var french := _squad(Type.SCOUT).plaque.text
	assert_true(french.begins_with("0\n"))
	assert_true(_squad(Type.ABYSS_ADMIRAL).plaque.text.begins_with("Caserne niv."))
	for language: String in ["en", "es"]:
		use_language(language)
		assert_no_raw_keys(_controller.army.tab)
		assert_no_raw_keys(modals())
		assert_ne(_squad(Type.SCOUT).plaque.text, french)
		assert_false(_squad(Type.ABYSS_ADMIRAL).plaque.text.begins_with("Caserne"))
		french = _squad(Type.SCOUT).plaque.text


func test_closing_the_controller_takes_the_tab_away() -> void:
	var tab := _controller.army.tab
	_controller.close()
	assert_false(is_instance_valid(tab))
	assert_eq(_world.view, WorldHost.View.BASE)

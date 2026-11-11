extends RivalGameCase
## test/presentation/screens/game/game_screen_map_actions_cells_test.dart,
## game_screen_map_actions_collect_test.dart: the sheet each touch opens.

const AT := Vector2i(2, 2)

var _router: CellRouter
var _routed: Array[CellRoute] = []


func _touch(x := AT.x, y := AT.y) -> void:
	_router = CellRouter.new(actions, modals())
	_router.route(1, x, y)


func _touch_with(content: Content, changes := {}, x := AT.x, y := AT.y) -> void:
	start({AT: cell_of(content, changes)})
	_touch(x, y)


func test_a_hidden_cell_opens_the_exploration() -> void:
	start({}, [AT], 1)
	_touch()
	assert_true(current_modal() is ExplorationSheet)
	assert_not_null(find_text("Explorer (2, 2)"))


func test_a_cell_already_collected_says_it_was_visited() -> void:
	_touch_with(Content.RUINS, {"collected_by": "someone"})
	assert_not_null(find_text("Déjà visité"))
	assert_not_null(find_text("Vous êtes déjà venu par ici"))
	assert_no_raw_keys()


func test_a_cell_taken_by_a_rival_names_it() -> void:
	start_with_rival({AT: cell_of(Content.RUINS, {"collected_by": Faction.new(RIVAL).id()})})
	_touch()
	assert_not_null(find_text(Texts.t(&"screenTakenByRivalTitle", {"name": rival.name()})))
	assert_not_null(find_text(Texts.t(&"screenTakenByRivalMessage")))
	assert_no_raw_keys()


func test_the_base_shows_the_headquarters() -> void:
	start()
	_touch(5, 5)
	assert_not_null(find_text("Votre base"))
	assert_not_null(find_text("Votre quartier général"))


func test_a_bare_cell_shows_a_plain() -> void:
	start()
	_touch(1, 4)
	assert_not_null(find_text("Plaine (1, 4)"))
	assert_not_null(find_text("Il n'y a rien à voir ici"))


func test_a_named_passage_shows_its_destination() -> void:
	_touch_with(Content.PASSAGE, {"passage_name": "la Fosse"})
	assert_not_null(find_text("Passage vers la Fosse"))
	assert_not_null(find_text(Texts.t(&"screenPassageMessage")))


func test_an_unnamed_passage_falls_back_to_unknown() -> void:
	_touch_with(Content.PASSAGE)
	assert_not_null(find_text("Passage vers passage inconnu"))


func test_a_treasure_opens_its_sheet_and_tells_what_the_search_found() -> void:
	_touch_with(Content.RESOURCE_BONUS)
	var sheet: TreasureSheet = current_modal()
	assert_true(sheet is TreasureSheet)
	press("Collecter le trésor")
	assert_true(current_modal() is ResourceGainDialog)
	assert_not_null(find_text("Trésor collecté !"))
	press("OK")
	assert_null(current_modal())


func test_ruins_and_a_wreck_have_their_own_titles() -> void:
	_touch_with(Content.RUINS)
	press("Collecter le trésor")
	assert_not_null(find_text("Ruines fouillées !"))
	_touch_with(Content.WRECK)
	press("Collecter le trésor")
	assert_not_null(find_text("Épave fouillée !"))


func test_ruins_found_empty_say_so() -> void:
	_touch_with(Content.RUINS)
	for resource: GameResource in human.resources.values():
		resource.amount = resource.max_storage
	press("Collecter le trésor")
	assert_not_null(find_text("Ruines fouillées !"))
	assert_not_null(find_text("Les ruines étaient vides..."))


func test_dismissing_the_treasure_sheet_tells_nothing() -> void:
	_touch_with(Content.RUINS)
	modals().close_top()
	assert_null(current_modal())


func test_a_kind_without_a_sheet_yet_is_coming_soon() -> void:
	_touch_with(Content.MONSTER_LAIR, {"lair": MonsterLair.new(MonsterDifficulty.Value.EASY, 3)})
	assert_not_null(find_text(Texts.t(&"screenComingSoon")))
	assert_not_null(find_text("(2, 2)"))
	assert_no_raw_keys()


func test_a_registered_handler_opens_its_kind_in_place_of_the_default() -> void:
	start({AT: cell_of(Content.MONSTER_LAIR, {"lair": MonsterLair.new(MonsterDifficulty.Value.EASY, 3)})})
	_router = CellRouter.new(actions, modals())
	_router.register(CellRoute.Kind.LAIR, _routed.append)
	_router.route(1, AT.x, AT.y)
	assert_null(current_modal())
	assert_eq(_routed.size(), 1)
	assert_eq([_routed[0].x, _routed[0].y, _routed[0].level], [2, 2, 1])
	assert_eq(_routed[0].kind, CellRoute.Kind.LAIR)


func test_a_handler_can_replace_a_kind_that_has_a_sheet() -> void:
	start({}, [], 0)
	_router = CellRouter.new(actions, modals())
	_router.register(CellRoute.Kind.HOME, _routed.append)
	_router.route(1, 5, 5)
	assert_eq(_routed.size(), 1)
	assert_null(current_modal())


func test_follows_the_language() -> void:
	start()
	_touch(1, 4)
	use_language("en")
	assert_not_null(find_text("Plain (1, 4)"))
	assert_not_null(find_text("There is nothing to see here"))

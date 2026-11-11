extends MapSheetCase
## test/presentation/widgets/map/treasure_sheet_test.dart and
## game_screen_map_actions_collect_test.dart: what a treasure holds and its
## search.

const AT := Vector2i(3, 3)

var _acted := 0
var _closed: Array[Variant] = []


func _open(content: Content) -> TreasureSheet:
	start({AT: cell_of(content)})
	actions.acted.connect(func(_result: Variant) -> void: _acted += 1)
	var sheet := TreasureSheet.new(actions, AT.x, AT.y, 1)
	modals().open(sheet)
	sheet.closed.connect(_closed.append)
	return sheet


func _total() -> int:
	var sum := 0
	for resource: GameResource in human.resources.values():
		sum += resource.amount
	return sum


func test_tells_what_each_kind_holds() -> void:
	var sheet := _open(Content.RESOURCE_BONUS)
	assert_eq(sheet.title_label.text, "Trésor (3, 3)")
	assert_not_null(find_text(Texts.t(&"mapTreasureResourceBonus")))
	assert_not_null(find_text("Collecter le trésor"))
	_open(Content.RUINS)
	assert_not_null(find_text(Texts.t(&"mapTreasureRuins")))
	_open(Content.WRECK)
	assert_not_null(find_text(Texts.t(&"mapTreasureWreck")))
	assert_no_raw_keys()


func test_promises_nothing_of_any_other_cell() -> void:
	var sheet := _open(Content.EMPTY)
	assert_eq(sheet._description(), "")


func test_searching_adds_the_loot_to_the_stocks_and_closes_with_it() -> void:
	var sheet := _open(Content.RESOURCE_BONUS)
	var before := _total()
	press(sheet.collect_button)
	assert_true(_total() > before)
	assert_eq(_acted, 1)
	assert_eq(_closed.size(), 1)
	var found: CollectTreasureResult = _closed[0]
	assert_false(found.deltas.is_empty())
	assert_true(game.levels[1].cell_at(AT.x, AT.y).is_collected())


func test_a_wreck_tells_its_countdown() -> void:
	start({AT: cell_of(Content.WRECK)})
	game.turn = 4
	human.event_state.wreck_position = GridPosition.new(AT.x, AT.y)
	human.event_state.wreck_until_turn = 6
	modals().open(TreasureSheet.new(actions, AT.x, AT.y, 1))
	assert_not_null(find_text("Épave : encore 3 tours"))


func test_a_cell_searched_meanwhile_is_refused_in_the_sheet() -> void:
	var sheet := _open(Content.RUINS)
	game.levels[1].set_cell(AT.x, AT.y, cell_of(Content.RUINS, {"collected_by": "me"}))
	press(sheet.collect_button)
	assert_true(sheet.failure_label.visible)
	assert_eq(sheet.failure_label.text, ActionFailureTexts.message(ActionFailure.Value.ALREADY_COLLECTED))
	assert_eq(_closed.size(), 0)
	assert_eq(_acted, 0)


func test_follows_the_language() -> void:
	var sheet := _open(Content.RUINS)
	use_language("en")
	assert_eq(sheet.title_label.text, "Treasure (3, 3)")
	assert_eq(sheet.collect_button.text, Texts.t(&"mapCollectTreasure"))
	assert_no_raw_keys()

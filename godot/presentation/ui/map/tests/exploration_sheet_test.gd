extends MapSheetCase
## test/presentation/widgets/map/exploration_sheet_test.dart and the flow of
## game_screen_map_actions_flow_test.dart, game_screen_map_storm_test.dart:
## sending a scout to a hidden cell.

var _acted := 0
var _closed: Array[Variant] = []


func _open(x := 6, y := 6, scouts := 2) -> ExplorationSheet:
	start({}, [Vector2i(x, y)], scouts)
	actions.acted.connect(func(_result: Variant) -> void: _acted += 1)
	var sheet := ExplorationSheet.new(actions, x, y, 1)
	modals().open(sheet)
	sheet.closed.connect(_closed.append)
	return sheet


func test_shows_the_target_the_cost_the_scouts_and_the_area() -> void:
	_open(6, 6, 4)
	assert_not_null(find_text("Explorer (6, 6)"))
	assert_not_null(find_text("1 éclaireur"))
	assert_not_null(find_text("4"))
	assert_not_null(find_text("3×3 cellules"))
	assert_not_null(find_text("+%d" % ExploreAction.new(6, 6, 1).noise_made(human)))
	assert_no_raw_keys()


func test_sending_queues_the_scout_and_closes_with_the_result() -> void:
	var sheet := _open()
	assert_false(sheet.send_button.disabled)
	press("Envoyer")
	assert_eq(human.pending_explorations.size(), 1)
	assert_eq(human.pending_explorations[0].target.x, 6)
	assert_eq(human.units_on_level(1)[Scout].count, 1)
	assert_eq(_acted, 1)
	assert_eq(_closed.size(), 1)
	assert_true(_closed[0] is ActionResult)


func test_without_scouts_the_button_is_disabled_and_says_why() -> void:
	var sheet := _open(6, 6, 0)
	assert_true(sheet.send_button.disabled)
	assert_not_null(find_text(ActionFailureTexts.message(ActionFailure.Value.NO_SCOUT_AVAILABLE)))


func test_a_far_cell_cannot_be_explored() -> void:
	start({}, [Vector2i(0, 2)], 1)
	see_only([Vector2i(5, 5)])
	var sheet := ExplorationSheet.new(actions, 0, 2, 1)
	modals().open(sheet)
	assert_true(sheet.send_button.disabled)
	assert_not_null(find_text("Cellule non éligible"))


func test_a_storm_closes_the_exploration_until_it_is_over() -> void:
	start({}, [Vector2i(3, 5)], 1)
	game.turn = 10
	human.event_state.activate(RandomEventType.Value.STORM, 11)
	var stormy := ExplorationSheet.new(actions, 3, 5, 1)
	modals().open(stormy)
	assert_true(stormy.send_button.disabled)
	assert_not_null(find_text("Tempête : exploration impossible"))
	human.event_state.activate(RandomEventType.Value.STORM, 9)
	var calm := ExplorationSheet.new(actions, 3, 5, 1)
	modals().open(calm)
	assert_false(calm.send_button.disabled)


func test_a_wreck_lying_there_tells_its_countdown() -> void:
	start({}, [Vector2i(6, 6)], 1)
	game.turn = 4
	human.event_state.wreck_position = GridPosition.new(6, 6)
	human.event_state.wreck_until_turn = 6
	modals().open(ExplorationSheet.new(actions, 6, 6, 1))
	assert_not_null(find_text("Épave : encore 3 tours"))


func test_a_refusal_at_the_moment_of_sending_is_told_in_the_sheet() -> void:
	var sheet := _open()
	give_scouts(0)
	sheet.send_button.pressed.emit()
	assert_true(sheet.failure_label.visible)
	assert_eq(sheet.failure_label.text, ActionFailureTexts.message(ActionFailure.Value.NO_SCOUT_AVAILABLE))
	assert_eq(_closed.size(), 0)


func test_follows_the_language() -> void:
	_open()
	use_language("en")
	assert_not_null(find_text("Explore (6, 6)"))
	assert_not_null(find_text("Send"))
	use_language("es")
	assert_no_raw_keys()

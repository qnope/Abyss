extends FactionControllerCase
## game_screen_faction_actions_test.dart: a touch on the base of a faction, its
## sheet, and the Scout that spies on it.


func test_a_touch_on_a_faction_base_opens_its_sheet() -> void:
	var sheet := open_rival()
	assert_not_null(sheet)
	assert_eq(sheet.identity.name_label.text, rival.name)
	assert_eq(sheet.headquarters_row.value_label.text, str(rival.buildings[BuildingType.Value.HEADQUARTERS].level))
	assert_null(sheet.intel_report)
	assert_false(sheet.attack_button.disabled)
	assert_null(find_text("Bientôt disponible"))
	assert_no_raw_keys(sheet)


func test_a_base_in_the_fog_still_starts_an_exploration() -> void:
	human.revealed_cells_per_level[1] = [] as Array[GridPosition]
	session.changed.emit()
	world.map.cell_tapped.emit(1, rival_at.x, rival_at.y)
	assert_false(current_modal() is FactionBaseSheet)
	assert_true(current_modal() is ExplorationSheet)


func test_a_cell_next_to_the_base_opens_no_faction_sheet() -> void:
	human.add_revealed_cell(1, GridPosition.new(rival_at.x + 1, rival_at.y))
	world.map.cell_tapped.emit(1, rival_at.x + 1, rival_at.y)
	assert_false(current_modal() is FactionBaseSheet)


func test_before_turn_10_the_attack_is_refused_with_the_reason() -> void:
	game.turn = 5
	var sheet := open_rival()
	assert_eq(sheet.failure_label.text, ActionFailureTexts.message(ActionFailure.Value.ATTACK_TOO_EARLY))
	assert_true(sheet.attack_button.disabled)


func test_the_scout_brings_a_report_and_the_sheet_opens_again_with_it() -> void:
	var scouts := stock(Scout)
	open_rival()
	press("Espionner")
	assert_eq(stock(Scout), scouts - 1, "the Scout does not come back")
	var sheet := current_modal() as FactionBaseSheet
	assert_not_null(sheet)
	assert_eq(modals().depth(), 1, "the first sheet is gone")
	var report := sheet.intel_report
	assert_not_null(report)
	assert_eq(report.intel.turn, 12)
	assert_eq(report.rampart_row.value_label.text, str(report.intel.rampart_level))
	assert_eq(report.freshness_label.text, "Valable encore 5 tours")
	assert_true(saved().human_player().intel().has(rival.id), "saved with the game")
	assert_eq(saved().human_player().units_on_level(1)[Scout].count, scouts - 1)
	assert_no_raw_keys(sheet)


func test_spying_again_renews_the_report() -> void:
	open_rival()
	press("Espionner")
	game.turn = 14
	session.changed.emit()
	press("Espionner")
	assert_eq((current_modal() as FactionBaseSheet).intel_report.intel.turn, 14)


func test_without_a_scout_spying_is_off() -> void:
	give({Harpoonist: 5})
	var sheet := open_rival()
	assert_true(sheet.spy_button.disabled)
	assert_false(sheet.attack_button.disabled)


func test_a_spy_the_domain_refuses_is_told_in_a_message() -> void:
	give({Harpoonist: 5})
	var sheet := open_rival()
	sheet.spy_button.disabled = false
	press("Espionner")
	var message := current_modal() as MessageDialog
	assert_not_null(message)
	assert_not_null(find_text(ActionFailureTexts.message(ActionFailure.Value.NOT_ENOUGH_UNITS), message))
	assert_null(human.intel().get(rival.id))
	assert_eq(repository.load_all().games.size(), 0, "nothing was saved")


func test_the_sheet_speaks_english_and_spanish() -> void:
	open_rival()
	press("Espionner")
	use_language("en")
	assert_not_null(find_text("Scout report"))
	assert_no_raw_keys()
	use_language("es")
	assert_no_raw_keys()

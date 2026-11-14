extends PostControllerCase
## test/presentation/screens/game/game_screen_transition_fight_flow_test.dart and
## game_screen_transition_actions_test.dart: a Faille of the map, the army sent
## against it, the report, the descent, and what the game kept.


func test_a_touch_on_a_guarded_faille_opens_its_sheet() -> void:
	world.map.cell_tapped.emit(1, faille_at.x, faille_at.y)
	assert_true(current_modal() is TransitionBaseSheet)
	assert_not_null(find_text("Assaut"))
	assert_null(find_text("Bientôt disponible"))


func test_the_assault_opens_the_army_with_the_units_of_the_level() -> void:
	var page := open_assault()
	assert_eq(page.rows.keys(), [Scout, Harpoonist, Guardian, Admiral])
	assert_eq(depth(), 1, "the sheet is gone")
	assert_true(page.actions_bar.launch_button.disabled)
	assert_true(page.actions_bar.admiral_label.visible)


func test_a_won_assault_takes_the_post_and_opens_the_report() -> void:
	var before := stock(Harpoonist)
	var page := open_assault()
	assault(page, Harpoonist, 150)
	var report := current_modal() as TransitionFightSummaryPage
	assert_not_null(report)
	assert_true(report.result.victory)
	assert_true(report.result.captured)
	assert_eq(faille().captured_by, human.id)
	assert_eq(stock(Harpoonist), before - report.result.dead.get(Harpoonist, 0), "the units are the domain's")
	assert_eq(on_level(1, Admiral), 1 - report.result.dead.get(Admiral, 0))
	assert_not_null(find_text("BASE CAPTURÉE", report))
	assert_eq(report.title(), "Assaut (%d, %d)" % [faille_at.x, faille_at.y])
	assert_no_raw_keys(report)


func test_the_assault_is_saved_and_the_post_is_lit_for_the_player_on_the_map() -> void:
	var before := MapProbe.tint_of(world.map.contents.by_cell[faille_at])
	assert_eq(before, MapPalette.HOLDERS[PostHolder.Value.GUARDIANS])
	assault(open_assault(), Harpoonist, 150)
	var kept := saved()
	assert_eq(kept.levels[1].cell_at(faille_at.x, faille_at.y).transition_base.captured_by, human.id)
	var after := MapProbe.tint_of(world.map.contents.by_cell[faille_at])
	assert_eq(after, MapPalette.HOLDERS[PostHolder.Value.HUMAN])
	assert_true(kept.human_player().history_entries.any(func(e: HistoryEntry) -> bool: return e is CaptureEntry))


func test_a_lost_assault_costs_units_and_leaves_the_post() -> void:
	give({Admiral: 1, Scout: 1})
	var page := open_assault()
	assault(page, Scout, 1)
	var report := current_modal() as TransitionFightSummaryPage
	assert_false(report.result.victory)
	assert_not_null(find_text("DÉFAITE", report))
	assert_null(faille().captured_by)
	assert_eq(on_level(1, Admiral), 1 - report.result.dead.get(Admiral, 0))
	assert_eq(on_level(1, Scout), 1 - report.result.dead.get(Scout, 0))
	assert_eq(saved().human_player().units_on_level(1)[Admiral].count, on_level(1, Admiral))


func test_cancelling_at_either_step_changes_nothing() -> void:
	world.map.cell_tapped.emit(1, faille_at.x, faille_at.y)
	modals().close_top()
	assert_null(current_modal())
	open_assault()
	press("Annuler")
	assert_null(current_modal())
	assert_eq(on_level(1, Harpoonist), 150)
	assert_null(faille().captured_by)
	assert_eq(saved_games().size(), 0, "nothing was saved")


func test_a_refusal_is_told_in_the_page_and_changes_nothing() -> void:
	var page := open_assault()
	page.rows[Admiral].set_value(1)
	page.rows[Harpoonist].set_value(10)
	give({Admiral: 1, Harpoonist: 5})
	press("Lancer l'assaut")
	assert_eq(current_modal(), page, "the page stays")
	assert_true(page.failure_label.visible)
	assert_eq(page.failure_label.text, ActionFailureTexts.message(ActionFailure.Value.NOT_ENOUGH_UNITS))
	assert_eq(on_level(1, Harpoonist), 5)


func test_a_post_taken_meanwhile_is_refused() -> void:
	var page := open_assault()
	faille().captured_by = "someone"
	page.rows[Admiral].set_value(1)
	press("Lancer l'assaut")
	assert_eq(page.failure_label.text, ActionFailureTexts.message(ActionFailure.Value.BASE_ALREADY_CAPTURED))


func test_a_faille_a_rival_holds_tells_the_attack_to_the_factions() -> void:
	var rival := game.players[game.factions()[0].id()]
	faille().captured_by = rival.id
	var told: Array[Array] = []
	controller.post.rival_attack_requested.connect(func(who: Player, level: int, x: int, y: int) -> void:
		told.append([who.id, level, x, y]))
	world.map.cell_tapped.emit(1, faille_at.x, faille_at.y)
	var sheet := current_modal() as RivalPostSheet
	assert_not_null(sheet)
	assert_eq(sheet.held_label.text, "Tenue par %s" % rival.name)
	var refusal: Variant = AttackPostValidator.refusal(game, human, 1, faille_at.x, faille_at.y)
	assert_eq(sheet.attack_button.disabled, refusal != null)
	sheet.attack_button.disabled = false
	press("Attaquer")
	assert_eq(told, [[rival.id, 1, faille_at.x, faille_at.y]] as Array[Array])


func test_the_post_sheets_speak_english_and_spanish() -> void:
	hold_faille()
	world.map.cell_tapped.emit(1, faille_at.x, faille_at.y)
	use_language("en")
	assert_no_raw_keys()
	use_language("es")
	assert_no_raw_keys()


func depth() -> int:
	return modals().depth()

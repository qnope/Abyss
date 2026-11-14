extends FactionControllerCase
## game_screen_faction_actions_test.dart and base_assault_summary_screen_test.dart:
## the army sent against the base of a faction, the report, and what the game
## kept.


func test_the_attack_opens_the_army_with_the_units_of_the_base_level() -> void:
	var page := open_rival_assault()
	assert_eq(page.title(), "Assaut : %s" % rival.name)
	assert_eq(page.rows.keys(), [Scout, Harpoonist, Guardian, Admiral])
	assert_eq(modals().depth(), 1, "the sheet is gone")
	assert_true(page.actions_bar.launch_button.disabled, "off until some units are picked")
	assert_false(page.actions_bar.admiral_label.visible, "no admiral is needed to attack a base")
	assert_eq(find_type("AssaultPlanPanel", page).size(), 0)
	assert_no_raw_keys(page)


func test_a_won_assault_pillages_the_base_and_opens_the_report() -> void:
	var before := stock(Harpoonist)
	var coral_before := rival_stock(ResourceType.Value.CORAL)
	var page := open_rival_assault()
	strike(page, Harpoonist, 40)
	var report := current_modal() as BaseAssaultSummaryPage
	assert_not_null(report)
	assert_true(report.victory)
	assert_false(report.entry.defending)
	assert_eq(report.entry.opponent_name, rival.name)
	assert_eq(report.title(), "Assaut : %s" % rival.name)
	assert_not_null(find_text("VICTOIRE", report))
	assert_not_null(find_text("Vous avez attaqué %s" % rival.name, report))
	var pillaged: int = report.entry.pillaged.get(ResourceType.Value.CORAL, 0)
	assert_eq(rival_stock(ResourceType.Value.CORAL), coral_before - pillaged, "the rival lost what the report says")
	assert_eq(stock(Harpoonist), before - report.entry.dead.get(Harpoonist, 0), "the units are the domain's")
	assert_eq(report.entry.units, {Harpoonist: 40})
	assert_no_raw_keys(report)


func test_the_assault_is_saved_and_told_to_both_sides() -> void:
	strike(open_rival_assault(), Harpoonist, 40)
	var kept := saved()
	var mine := assaults(kept.human_player())
	var theirs := assaults(game.players[rival.id])
	assert_eq([mine.size(), theirs.size()], [1, 1])
	assert_false(mine[0].defending)
	assert_true(theirs[0].defending)
	assert_eq(kept.players[rival.id].resources[ResourceType.Value.CORAL].amount, rival_stock(ResourceType.Value.CORAL))


func test_a_lost_assault_costs_units_and_leaves_the_base_alone() -> void:
	wall_up()
	var coral_before := rival_stock(ResourceType.Value.CORAL)
	var rampart_before: int = rival.buildings[BuildingType.Value.CORAL_CITADEL].level
	var before := stock(Harpoonist)
	strike(open_rival_assault(), Harpoonist, 3)
	var report := current_modal() as BaseAssaultSummaryPage
	assert_false(report.victory)
	assert_not_null(find_text("DÉFAITE", report))
	assert_null(find_text("Rempart : niveau %d → %d" % [rampart_before, 0], report))
	assert_eq(find_type("FightLootCard", report).size(), 0)
	assert_eq(stock(Harpoonist), before - report.entry.dead.get(Harpoonist, 0))
	assert_eq(rival_stock(ResourceType.Value.CORAL), coral_before)
	assert_eq(rival.buildings[BuildingType.Value.CORAL_CITADEL].level, rampart_before)
	assert_eq(saved().human_player().units_on_level(1)[Harpoonist].count, stock(Harpoonist))


func test_cancelling_at_either_step_changes_nothing() -> void:
	open_rival()
	press("Annuler")
	assert_null(current_modal())
	open_rival_assault()
	press("Annuler")
	assert_null(current_modal())
	assert_eq(stock(Harpoonist), 150)
	assert_eq(saved_games().size(), 0, "nothing was saved")


func test_a_refusal_is_told_in_the_page_and_changes_nothing() -> void:
	var page := open_rival_assault()
	page.rows[Harpoonist].set_value(10)
	give({Harpoonist: 5})
	press("Lancer l'assaut")
	assert_eq(current_modal(), page, "the page stays")
	assert_true(page.failure_label.visible)
	assert_eq(page.failure_label.text, ActionFailureTexts.message(ActionFailure.Value.NOT_ENOUGH_UNITS))
	assert_eq(stock(Harpoonist), 5)
	assert_eq(rival.history_entries.size(), 0)


func test_a_second_strike_the_same_turn_is_refused_at_the_sheet() -> void:
	strike(open_rival_assault(), Harpoonist, 40)
	current_modal().close()
	var sheet := open_rival()
	assert_true(sheet.attack_button.disabled)
	assert_eq(sheet.failure_label.text, ActionFailureTexts.message(ActionFailure.Value.ALREADY_ATTACKED_THIS_TURN))


func test_the_pages_speak_english_and_spanish() -> void:
	var page := open_rival_assault()
	use_language("en")
	assert_eq(page.title(), "Assault: %s" % rival.name)
	assert_no_raw_keys(page)
	use_language("fr")
	strike(page, Harpoonist, 40)
	use_language("es")
	assert_no_raw_keys(current_modal())
	use_language("en")
	assert_not_null(find_text("You attacked %s" % rival.name, current_modal()))
	assert_no_raw_keys(current_modal())

extends UiTestCase
## The threats through the end of a turn: the warning of the question, the
## lines of the summary and the reports that follow it
## (test/presentation/screens/game/game_screen_turn_flow_volcano_test.dart,
## game_screen_predators_warning_test.dart).

var _told: Array[String] = []
var _game: Game
var _human: Player
## The outcome under test: whoever runs one keeps it, as the flow does.
var _outcome: TurnOutcome


func before_each() -> void:
	_game = GameFactory.new_single_player("Nemo", 1)
	_game.turn = 12
	_human = _game.human_player()


func _flow() -> EndTurnFlow:
	var flow := EndTurnFlow.new(GameActions.new(_game), modals())
	flow.finished.connect(_told.append.bind("finished"))
	flow.defeated.connect(_told.append.bind("defeated"))
	return flow


func _run(result: TurnResult) -> void:
	_outcome = TurnOutcome.new(_game, result, modals(), TurnOutcome.default_steps())
	_outcome.finished.connect(_told.append.bind("finished"))
	_outcome.run()


func test_the_default_queue_follows_the_summary_with_the_reports_of_the_threats() -> void:
	var steps := TurnOutcome.default_steps()
	assert_eq(steps, [TurnOutcome.summary_page, ThreatPages.raid, ThreatPages.predators, ThreatPages.volcano] as Array[Callable])


func test_a_raid_fought_opens_its_report_after_the_summary_and_closes_into_the_next_step() -> void:
	_run(ThreatSamples.result(ThreatSamples.raid_report(false)))
	assert_true(current_modal() is TurnSummary)
	press("OK")
	var page := current_modal() as RaidReportPage
	assert_not_null(page)
	assert_eq(page.report.victory, false)
	assert_eq(_told, [] as Array[String])
	press("Retour à la base")
	assert_null(current_modal())
	assert_eq(_told, ["finished"] as Array[String])


func test_the_raid_comes_before_the_predators_and_the_wave_lost_after_them() -> void:
	var predators := ThreatSamples.raid_report(true, 0, true)
	var result := ThreatSamples.result(ThreatSamples.raid_report(true), null, ThreatSamples.volcano_report(false), null, predators)
	_run(result)
	press("OK")
	var order: Array[String] = []
	for _page in 3:
		var page := current_modal()
		if page is RaidReportPage:
			order.append("predators" if (page as RaidReportPage).report.surprise else "raid")
		else:
			order.append("volcano")
		press("Retour à la base")
	assert_eq(order, ["raid", "predators", "volcano"] as Array[String])
	assert_eq(_told, ["finished"] as Array[String])


func test_a_wave_repelled_has_no_page_of_its_own() -> void:
	_run(ThreatSamples.result(null, null, ThreatSamples.volcano_report(true)))
	press("OK")
	assert_null(current_modal())
	assert_eq(_told, ["finished"] as Array[String])


func test_a_turn_with_no_threat_has_only_its_summary() -> void:
	_run(ThreatSamples.result())
	press("OK")
	assert_eq(_told, ["finished"] as Array[String])


func test_a_raid_due_is_warned_of_then_told_in_the_summary_then_reported() -> void:
	var wave := ThreatSamples.wave()
	_human.raid_state.announce(wave, 12)
	var flow := _flow()
	flow.request()
	assert_not_null(find_text("Raid ce tour : %s contre aucun défenseur" % MonsterLairTexts.wave_label(wave)))
	press("Confirmer")
	assert_eq(_game.turn, 13)
	assert_not_null(find_text("La base a été pillée"))
	assert_no_raw_keys()
	press("OK")
	assert_true(current_modal() is RaidReportPage)
	assert_not_null(find_text("Raid sur la base (tour 12)"))
	assert_no_raw_keys()
	press("Retour à la base")
	assert_eq(_told, ["finished"] as Array[String])
	assert_eq(_human.raid_state.lost_in_a_row, 1)


func test_a_kernel_wave_due_is_warned_of_and_its_loss_reported() -> void:
	_human.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 1
	_human.volcano_state.announce(VolcanoWaveFactory.from_kernel_level(1), 12)
	var flow := _flow()
	flow.request()
	var wave_text := MonsterLairTexts.wave_label(_human.volcano_state.incoming)
	assert_not_null(find_text(text(&"volcanoDueWarning", {"wave": wave_text})))
	press("Confirmer")
	assert_not_null(find_text("Volcan : le Noyau retombe au niveau 0"))
	press("OK")
	assert_true(current_modal() is VolcanoReportPage)
	press("Retour à la base")
	assert_eq(_told, ["finished"] as Array[String])

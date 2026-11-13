extends StoryFlowCase
## "Next turn" through the game screen: the turn resolved, its story told on the map,
## then the summary (game_screen_story.dart, game_screen_end_turn.dart).


## A raid due at the end of this turn, and the end of the turn confirmed.
func _end_turn_with_a_raid() -> void:
	game.turn = 12
	human.raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.EASY, 5), 12)
	_end_turn()


func _end_turn() -> void:
	press("Tour suivant")
	press("Confirmer")


func test_a_raid_is_told_as_a_siege_of_the_base_before_the_summary() -> void:
	_end_turn_with_a_raid()
	assert_true(world.map.effects.current is SiegeEffect)
	assert_null(current_modal(), "the summary waits for the story")
	assert_not_null(find_text("Passer ›"), "the skip floats over the map")
	run_effect()
	assert_true(current_modal() is TurnSummary)
	assert_null(find_text("Passer ›"), "the skip is gone with the story")


func test_the_turn_is_saved_before_the_story_is_over() -> void:
	_end_turn_with_a_raid()
	assert_eq(repository.load_all().games[0].turn, 13)
	assert_eq(game.turn, 13)


func test_skipping_opens_the_summary_at_once_once() -> void:
	_end_turn_with_a_raid()
	press("Passer ›")
	assert_false(world.map.effects.is_playing())
	assert_true(current_modal() is TurnSummary)
	assert_eq(modals().depth(), 1)
	press("OK")
	assert_true(current_modal() is RaidReportPage, "the pages go on as they always did")


func test_the_story_opens_the_map_tab_for_a_player_on_another_tab() -> void:
	press("Base")
	_end_turn_with_a_raid()
	assert_eq(hud.tab, GameTab.Value.MAP)
	assert_true(world.map.effects.current is SiegeEffect)


func test_a_turn_with_nothing_to_tell_opens_the_summary_at_once() -> void:
	press("Base")
	_end_turn()
	assert_true(current_modal() is TurnSummary)
	assert_eq(hud.tab, GameTab.Value.BASE, "the player stays where he was")
	assert_null(find_text("Passer ›"))


func test_a_scout_that_explores_lifts_the_fog_before_the_summary() -> void:
	var cell := Vector2i.ZERO
	var seen := human.revealed_cells_set_on_level(1)
	for x in game.levels[1].width:
		if CellEligibilityChecker.is_eligible(game.levels[1], human, x, 0) and not seen.has(Vector2i(x, 0)):
			cell = Vector2i(x, 0)
	human.pending_explorations.append(ExplorationOrder.new(GridPosition.new(cell.x, cell.y), 1))
	_end_turn()
	assert_true(world.map.effects.current is FogLift, "the clouds lift over the cells seen")
	assert_null(current_modal())
	run_effect()
	assert_true(current_modal() is TurnSummary)


func test_leaving_the_map_ends_the_story_since_its_world_is_paused() -> void:
	_end_turn_with_a_raid()
	press("Base")
	assert_true(current_modal() is TurnSummary)
	assert_null(find_text("Passer ›"))


func test_a_player_who_wants_fewer_animations_is_told_no_story() -> void:
	world.map.effects.reduced_motion = true
	assert_false(controller.story.observe().is_valid())
	press("Base")
	_end_turn_with_a_raid()
	assert_true(current_modal() is TurnSummary)
	assert_eq(hud.tab, GameTab.Value.BASE)


func test_a_screen_closed_during_the_story_never_opens_the_summary() -> void:
	_end_turn_with_a_raid()
	controller.story.close()
	run_effect()
	assert_null(current_modal())
	assert_null(find_text("Passer ›"))


func test_no_second_turn_can_be_asked_during_the_story() -> void:
	_end_turn_with_a_raid()
	press("Tour suivant")
	assert_null(current_modal())
	assert_eq(game.turn, 13)


func test_no_tip_opens_over_the_story_the_summary_comes_first() -> void:
	human.saved_objective_state = ObjectiveState.new([], false, true)
	human.raid_state.add_noise(DartMath.trunc_div(NoiseRules.THRESHOLD, 4))
	_end_turn_with_a_raid()
	controller.tips._show()
	assert_null(current_modal(), "the tips of a turn come last in its pages")
	press("Passer ›")
	assert_true(current_modal() is TurnSummary)

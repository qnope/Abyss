extends TestCase
## test/domain/leviathan/leviathan_schedule_test.dart: the first Faille the
## human takes schedules the guardians' return, once per game.

const ARMY: Dictionary[UnitType.Value, int] = {
	UnitType.Value.ABYSS_ADMIRAL: 1, UnitType.Value.GUARDIAN: 30, UnitType.Value.HARPOONIST: 30,
}


func _capture(game: Game, player: Player) -> bool:
	var result := AttackTransitionBaseAction.new(1, 1, 1, ARMY, DartRandom.new(42)).execute(game, player)
	var map: GameMap = game.levels[1]
	return result.is_success and map.cell_at(1, 1).transition_base.captured_by == player.id


func test_a_new_game_can_still_get_the_counter_attack() -> void:
	var game := SiegeSamples.attack_game()
	assert_true(game.leviathan_return.is_available())
	assert_false(game.leviathan_return.is_scheduled())


func test_the_first_faille_taken_by_the_human_strikes_back_3_turns_later() -> void:
	var game := SiegeSamples.attack_game(ARMY)
	game.turn = 9
	assert_true(_capture(game, game.human_player()))
	var state := game.leviathan_return
	assert_eq(LeviathanReturn.DELAY, 3)
	assert_true(state.is_scheduled())
	assert_false(state.is_available())
	assert_eq(state.strike_turn, 12)
	assert_eq(state.post_name, "Faille")
	assert_eq(state.level, 1)
	assert_true(state.at.equals(GridPosition.new(1, 1)))


func test_a_cheminee_taken_does_not_bring_the_guardians_back() -> void:
	var army: Dictionary[UnitType.Value, int] = {
		UnitType.Value.ABYSS_ADMIRAL: 1, UnitType.Value.GUARDIAN: 60, UnitType.Value.DOME_BREAKER: 60,
	}
	var game := SiegeSamples.attack_game(army, TransitionBaseType.Value.CHEMINEE)
	AttackTransitionBaseAction.new(1, 1, 1, army, DartRandom.new(42)).execute(game, game.human_player())
	var map: GameMap = game.levels[1]
	assert_eq(map.cell_at(1, 1).transition_base.captured_by, game.human_player().id)
	assert_true(game.leviathan_return.is_available())


func test_only_the_first_capture_schedules_it_once_per_game() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE, 7, true)
	var state := war.game.leviathan_return
	LeviathanResolver.on_capture(war.game, war.human(), war.post, war.level, war.at)
	var strike: int = state.strike_turn
	state.end()
	war.game.turn += 10
	LeviathanResolver.on_capture(war.game, war.human(), war.post, war.level, war.at)
	assert_eq(state.strike_turn, strike)
	assert_false(state.is_scheduled())


func test_a_faction_taking_a_faille_never_gets_it() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE)
	LeviathanResolver.on_capture(war.game, war.owner(), war.post, war.level, war.at)
	assert_true(war.game.leviathan_return.is_available())


func test_a_game_saved_before_the_counter_attack_never_gets_it() -> void:
	var game := SiegeSamples.attack_game(ARMY)
	game.leviathan_return = null
	assert_true(_capture(game, game.human_player()))
	assert_null(game.leviathan_return)
	assert_null(LeviathanResolver.announced_now(game))
	var outcome := LeviathanResolver.resolve(game)
	assert_null(outcome.report)
	assert_null(outcome.announced)

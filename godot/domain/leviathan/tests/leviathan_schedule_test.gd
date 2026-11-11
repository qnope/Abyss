extends TestCase
## test/domain/leviathan/leviathan_schedule_test.dart: the first Faille the
## human takes schedules the guardians' return, once per game. The three
## tests that capture with AttackTransitionBaseAction come with it.


func test_a_new_game_can_still_get_the_counter_attack() -> void:
	var game := SiegeSamples.attack_game()
	assert_true(game.leviathan_return.is_available())
	assert_false(game.leviathan_return.is_scheduled())


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

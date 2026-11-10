extends TestCase
## test/domain/action/attack_base/attack_base_once_a_turn_test.dart: a base
## is attacked once a turn at most by the same player.

const HORDE := AssaultSamples.HORDE


func test_a_base_is_attacked_once_a_turn_at_most_by_the_same_player() -> void:
	var game := AssaultSamples.assault_game()
	var human := game.human_player()
	AssaultSamples.station(human, HORDE)
	assert_true(ActionExecutor.new().execute(AssaultSamples.strike(game, HORDE), game, human).is_success)
	AssaultSamples.station(human, HORDE)
	assert_eq(AssaultSamples.strike(game, HORDE).validate(game, human).reason, ActionFailure.Value.ALREADY_ATTACKED_THIS_TURN)
	assert_eq(AttackBaseValidator.refusal(game, human, AssaultSamples.rival_of(game).id),
		ActionFailure.Value.ALREADY_ATTACKED_THIS_TURN)


func test_the_next_turn_it_can_be_attacked_again() -> void:
	var game := AssaultSamples.assault_game()
	var human := game.human_player()
	AssaultSamples.station(human, HORDE)
	ActionExecutor.new().execute(AssaultSamples.strike(game, HORDE), game, human)
	game.turn += 1
	AssaultSamples.station(human, HORDE)
	assert_null(AttackBaseValidator.refusal(game, human, AssaultSamples.rival_of(game).id))

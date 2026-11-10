extends TestCase
## test/domain/action/attack_base/attack_base_truce_test.dart: nobody
## attacks before the first raid, nor a player still in the tutorial.

const HORDE := AssaultSamples.HORDE


func _tutorial(player: Player, game: Game, done: bool) -> void:
	var state := ObjectiveMigration.state_of(game, player)
	state.tutorial_enabled = true
	state.completed.clear()
	if done:
		for objective: Objective in InstallationObjectives.installation_objectives():
			state.complete(objective.id)


func test_no_attack_before_turn_10_without_the_tutorial() -> void:
	var early := AssaultSamples.assault_game(9)
	AssaultSamples.station(early.human_player(), HORDE)
	var ready := AssaultSamples.assault_game(10)
	AssaultSamples.station(ready.human_player(), HORDE)
	assert_eq(AssaultSamples.strike(early, HORDE).validate(early, early.human_player()).reason,
		ActionFailure.Value.ATTACK_TOO_EARLY)
	assert_true(AssaultSamples.strike(ready, HORDE).validate(ready, ready.human_player()).is_success)


func test_no_attack_while_the_tutorial_chapter_is_unfinished() -> void:
	var game := AssaultSamples.assault_game(30)
	var human := game.human_player()
	AssaultSamples.station(human, HORDE)
	_tutorial(human, game, false)
	assert_eq(AssaultSamples.strike(game, HORDE).validate(game, human).reason, ActionFailure.Value.ATTACK_TOO_EARLY)
	_tutorial(human, game, true)
	assert_true(AssaultSamples.strike(game, HORDE).validate(game, human).is_success)


func test_a_player_still_in_the_tutorial_cannot_be_attacked_either() -> void:
	var game := AssaultSamples.assault_game(30)
	var rival := AssaultSamples.rival_of(game)
	AssaultSamples.station(rival, HORDE)
	_tutorial(game.human_player(), game, false)
	var action := AttackBaseAction.new(game.human_player().id, HORDE)
	assert_eq(action.validate(game, rival).reason, ActionFailure.Value.ATTACK_TOO_EARLY)

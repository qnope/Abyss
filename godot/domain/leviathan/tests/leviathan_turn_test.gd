extends TestCase
## test/domain/leviathan/leviathan_turn_test.dart: the guardians announced,
## then fought, through the ends of turn.


static func _end(war: PostWar) -> TurnResult:
	var result: EndTurnActionResult = ActionExecutor.new().execute(
		EndTurnAction.new(DartRandom.new(5), false), war.game, war.human()
	)
	return result.turn_result


func test_the_end_of_turn_announces_the_guardians_then_fights_them() -> void:
	var war := LeviathanScene.of()
	var strike_turn := LeviathanScene.strike_turn(war)
	var result := _end(war)
	assert_null(result.announced_leviathan)
	assert_null(result.leviathan)
	while war.game.turn < strike_turn - 1:
		_end(war)

	result = _end(war)
	assert_eq(result.announced_leviathan.turn, strike_turn)
	assert_eq(result.announced_leviathan.post_name, war.post.name)
	assert_null(result.leviathan)

	result = _end(war)
	var report := result.leviathan
	assert_eq(report.attacker_name, LeviathanForce.ATTACKER_NAME)
	assert_eq(report.outcome(), AttackOutcome.Value.POST_TAKEN)
	assert_has(result.attacks, report)
	assert_eq(war.human().buildings[BuildingType.Value.DESCENT_MODULE].level, 0)
	assert_null(war.post.captured_by)

extends TestCase
## test/domain/objective/guide/guide_leviathan_test.dart: the guide's alert
## on the turn the guardians strike the Faille. The Dart tests read it
## through GuideAdvisor.of, which puts it first and waits for GuideCampaign
## (`faction`); these read GuideLeviathan.of, what GuideAdvisor returns
## then. The last test, the tutorial off, waits for GuideAdvisor.

const HARPOONIST := UnitType.Value.HARPOONIST


## The scene on the turn the guardians strike, the tutorial on.
func _strike_turn() -> PostWar:
	var war := LeviathanScene.of()
	LeviathanScene.play_until(war, LeviathanScene.strike_turn(war))
	ObjectiveMigration.state_of(war.game, war.human()).tutorial_enabled = true
	return war


func _advice(war: PostWar) -> GuideAdvice:
	return GuideLeviathan.of(war.game, war.human())


func _needed(war: PostWar) -> int:
	return LeviathanDefenceAdvisor.units_for(war.game, war.human(), 2)


func test_comes_first_on_the_turn_the_guardians_strike() -> void:
	var war := _strike_turn()
	var expected := GuideAdvice.new(GuideLeviathanReturn.new(2, _needed(war)), GuideTarget.for_cell(war.level, war.at))
	assert_true(_advice(war).equals(expected), str(_advice(war)))


func test_counts_the_units_already_on_level_2() -> void:
	var war := _strike_turn()
	war.put(war.human(), 2, {HARPOONIST: 1})
	var message := _advice(war).message
	assert_true(message.equals(GuideLeviathanReturn.new(2, _needed(war) - 1)), str(message))


func test_asks_for_none_once_level_2_should_hold() -> void:
	var war := _strike_turn()
	war.put(war.human(), 2, {UnitType.Value.GUARDIAN: 200, HARPOONIST: 200})
	var message := _advice(war).message
	assert_true(message.equals(GuideLeviathanReturn.new(2)), str(message))


func test_says_nothing_before_the_turn_they_strike() -> void:
	var war := LeviathanScene.of()
	LeviathanScene.play_until(war, LeviathanScene.strike_turn(war) - 1)
	ObjectiveMigration.state_of(war.game, war.human()).tutorial_enabled = true
	assert_null(_advice(war))


## Not in the Dart file: the alert is the human's alone.
func test_says_nothing_to_another_player() -> void:
	var war := _strike_turn()
	assert_not_null(_advice(war))
	assert_null(GuideLeviathan.of(war.game, war.attacker()))

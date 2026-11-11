extends TestCase
## test/domain/leviathan/leviathan_postponed_test.dart: the strike waits for
## the Module de descente to work, nobody could defend the Faille before.

const MODULE := BuildingType.Value.DESCENT_MODULE


## The scene, the Faille taken at turn 12 with no Module de descente.
func _no_module() -> PostWar:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE, 7, true)
	war.human().buildings[MODULE] = Building.new(MODULE, 0)
	LeviathanResolver.on_capture(war.game, war.human(), war.post, war.level, war.at)
	return war


func _build_module(war: PostWar) -> void:
	war.human().buildings[MODULE].level = 1


func test_a_working_module_at_the_capture_strikes_3_turns_later() -> void:
	var war := LeviathanScene.of()
	assert_eq(LeviathanScene.leviathan(war).due_turn(), 15)


func test_without_a_working_module_the_strike_is_postponed() -> void:
	var war := _no_module()
	assert_true(LeviathanScene.leviathan(war).is_scheduled())
	assert_null(LeviathanScene.leviathan(war).due_turn())
	for _i: int in 8:
		var outcome := LeviathanScene.end_turn(war)
		assert_null(outcome.announced)
		assert_null(outcome.report)
		assert_null(LeviathanResolver.announced_now(war.game))
	assert_true(LeviathanScene.leviathan(war).is_scheduled())


func test_a_module_built_later_strikes_3_turns_after_it() -> void:
	var war := _no_module()
	LeviathanScene.play_until(war, 16)
	_build_module(war)
	assert_null(LeviathanScene.end_turn(war).announced)
	assert_eq(LeviathanScene.leviathan(war).due_turn(), 19)
	LeviathanScene.play_until(war, 18)
	assert_eq(LeviathanScene.end_turn(war).announced.turn, 19)
	assert_not_null(LeviathanScene.end_turn(war).report)
	assert_false(LeviathanScene.leviathan(war).is_scheduled())


func test_a_module_built_soon_after_the_capture_keeps_capture_plus_3() -> void:
	var war := _no_module()
	_build_module(war)
	LeviathanScene.end_turn(war)
	assert_eq(LeviathanScene.leviathan(war).due_turn(), 15)


func test_a_degraded_module_does_not_count_as_working() -> void:
	var war := _no_module()
	_build_module(war)
	war.human().buildings[BuildingType.Value.HEADQUARTERS].level = 1
	assert_true(war.human().is_degraded(MODULE))
	LeviathanScene.end_turn(war)
	assert_null(LeviathanScene.leviathan(war).due_turn())


func test_a_module_working_while_the_faille_is_lost_does_not_count() -> void:
	var war := _no_module()
	war.post.captured_by = war.attacker().id
	_build_module(war)
	LeviathanScene.end_turn(war)
	assert_null(LeviathanScene.leviathan(war).due_turn())

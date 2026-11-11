extends TestCase
## test/domain/script/event_choice_precedence_test.dart.

var _other_dice := ReplayVariant.new(true, false)


func test_the_careful_strategy_and_its_rush_answer_the_events() -> void:
	assert_eq(_play(ConquestStrategy.new()), true)
	assert_eq(_play(ConquestStrategy.new(null, 0.5, true, false)), true)


func test_a_plan_without_a_choice_that_turn_lets_the_bot_rules_choose() -> void:
	assert_eq(_play(PlanScript.from_replay(_refusing_plan(30), _other_dice)), true)


func test_a_plans_recorded_choice_is_played_instead_of_the_bot_rule() -> void:
	assert_eq(_play(PlanScript.from_replay(_refusing_plan(), _other_dice)), false)


func test_the_exact_replay_of_a_plan_only_plays_what_was_recorded() -> void:
	assert_null(_play(PlanScript.from_replay(_refusing_plan(30), ReplayVariant.new())))


func test_a_scenarios_recorded_choice_wins_over_its_fallback_strategy() -> void:
	assert_eq(_play(_refusing_scenario(12)), false)
	assert_eq(_play(_refusing_scenario(11)), true)


## A scenario that refuses the event of `turn`, the careful strategy playing
## the other turns.
static func _refusing_scenario(turn: int) -> TimelineScript:
	var refuse := func(_r: DartRandom) -> Action: return ChooseEventAction.new(false)
	var turns: Dictionary[int, Array] = {turn: [refuse]}
	return TimelineScript.new("scenario", turns, ConquestStrategy.new())


## Turn 12 of a new game, quiet enough to exploit the warm current that
## waits for a choice: every bot exploits it.
static func _warm_turn() -> ScriptTurn:
	var game := GameFactory.new_single_player("p", 5)
	game.turn = 12
	game.human_player().event_state.schedule(100)
	game.human_player().event_state.set_pending(RandomEventType.Value.WARM_CURRENT, 12)
	return EventMoveSamples.script_turn_of(game)


## Plan that refuses the event of `turn`, as a human did.
static func _refusing_plan(turn := 12) -> String:
	return DartJson.encode({"turns": {str(turn): [{"do": "event", "accept": false}]}})


static func _play(script: GameScript) -> Variant:
	var turn := _warm_turn()
	script.play_turn(turn)
	return EventMoveSamples.choice_of(turn.player)

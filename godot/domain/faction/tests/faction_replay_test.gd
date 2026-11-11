extends TestCase
## test/domain/faction/faction_replay_test.dart, its last test. 'a replay
## never asks a brain: the journal alone gives the game' waits for
## `ScenarioParser` and `ScriptRunner`, 'a timeline replays factions without
## brains by default' for `TimelineScript`, 'a strategy lets the brains
## play' for `GameScript.factionsPlay`: the runners of `script`.


func test_the_end_of_turn_without_the_switch_plays_no_brain() -> void:
	var game := FactionGames.play(2, 1)
	var before := game.replay.actions_of(1).size()
	EndTurnAction.new(DartRandom.new(1, false), false).execute(game, game.human_player())

	assert_eq(game.replay.actions_of(1).size(), before)

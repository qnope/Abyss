extends TestCase
## test/domain/script/script_player_helpers_test.dart: the helpers of a
## script answer for the player of its turn. 'milestones follow the player
## they are asked about' waits for `ScriptMilestones`, with the runner.


func test_own_base_and_open_base_answer_for_the_turn_player() -> void:
	var game := GameSamples.two_players()
	var rival := AssaultSamples.rival_of(game)
	var map := game.levels[1]
	var index := -1
	for i: int in map.cells.size():
		if map.cells[i].content == CellContentType.Value.TRANSITION_BASE:
			index = i
			break
	var faille := map.cells[index]
	var at := GridPosition.new(index % map.width, DartMath.trunc_div(index, map.width))
	for p: Player in [game.human_player(), rival]:
		p.add_revealed_cell(1, at)

	assert_true(ExpeditionMoves.open_base(ScriptSamples.turn(game, rival), 1).equals(at))
	assert_null(ExpeditionMoves.own_base(ScriptSamples.turn(game, rival), 1))

	faille.transition_base.captured_by = rival.id

	assert_true(ExpeditionMoves.own_base(ScriptSamples.turn(game, rival), 1).equals(at))
	assert_null(ExpeditionMoves.own_base(ScriptSamples.turn(game), 1))
	assert_null(ExpeditionMoves.open_base(ScriptSamples.turn(game), 1))

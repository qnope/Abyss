extends TestCase
## test/domain/script/script_player_helpers_test.dart: the helpers of a
## script answer for the player of its turn, and milestones follow the
## player they are asked about.


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


func test_milestones_follow_the_player_they_are_asked_about() -> void:
	var game := GameSamples.two_players()
	var rival := AssaultSamples.rival_of(game)
	for cell: MapCell in game.levels[1].cells:
		if cell.content == CellContentType.Value.TRANSITION_BASE:
			cell.transition_base.captured_by = rival.id
			break

	var human := ScriptMilestones.new()
	human.observe(game, 5)
	var by_rival := ScriptMilestones.new()
	by_rival.observe(game, 5, rival.id)

	assert_null(human.faille_captured if human.faille_captured != null else human.cheminee_captured)
	assert_eq(by_rival.faille_captured if by_rival.faille_captured != null else by_rival.cheminee_captured, 5)

extends TestCase
## test/domain/action/descend_action_passages_test.dart: the level reached
## keeps a passage under each Faille above.

const PASSAGE := CellContentType.Value.PASSAGE


func _descend(game: Game) -> GameMap:
	DescendAction.new(5, 5, 1, {UnitType.Value.SCOUT: 1}).execute(game, game.human_player())
	return game.levels[2]


func test_descend_action_passage_reservation_generates_level_2_with_passage_cells_at_faille_positions() -> void:
	var game := MoveSamples.descend_game()
	var parent := game.levels[1]
	var failles: Dictionary[Vector2i, String] = {}
	for y: int in parent.height:
		for x: int in parent.width:
			var cell := parent.cell_at(x, y)
			if cell.content == CellContentType.Value.TRANSITION_BASE and cell.transition_base != null:
				failles[Vector2i(x, y)] = cell.transition_base.name
	assert_false(failles.is_empty())
	var level2 := _descend(game)
	for at: Vector2i in failles:
		var cell := level2.cell_at(at.x, at.y)
		# May overlap with the base cell, which gets cleared
		if cell.content == CellContentType.Value.EMPTY:
			continue
		assert_eq(cell.content, PASSAGE)
		assert_eq(cell.passage_name, failles[at])


func test_descend_action_passage_reservation_passage_cells_have_no_lair_or_transition_base() -> void:
	var level2 := _descend(MoveSamples.descend_game())
	for cell: MapCell in level2.cells:
		if cell.content == PASSAGE:
			assert_null(cell.lair)
			assert_null(cell.transition_base)


func test_descend_action_passage_reservation_multiple_failles_produce_multiple_passages() -> void:
	var game := MoveSamples.descend_game()
	var faille := TransitionBase.new(TransitionBaseType.Value.FAILLE, "Faille B", "test")
	game.levels[1].set_cell(3, 3, MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.TRANSITION_BASE, null, null, faille))
	var level2 := _descend(game)
	var passages := 0
	for cell: MapCell in level2.cells:
		if cell.content == PASSAGE:
			passages += 1
	assert_true(passages >= 2)

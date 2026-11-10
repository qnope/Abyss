extends TestCase
## Not in the Dart files: the cells the halo points at, which the Dart tests
## read through GuideCampaign (guide_campaign_*_test.dart), waiting for
## AssaultPlan and UndefendedPosts. The values are what a scratch Dart
## script printed on GameFactory.newGame(playerName: 'Nemo', mapSeed: 7,
## factionCount: 2, humanId: 'human').

const Target := AssaultTarget.Value


func test_the_posts_and_the_kernel_of_a_generated_game() -> void:
	var game := GameFactory.new_game("Nemo", 7, Difficulty.Value.NORMAL, false, 2, null, "human")
	var human := game.human_player()
	for level: int in [1, 2, 3]:
		assert_null(GuideMap.nearest(game, human, Target.FAILLE, level), str(level))
	assert_null(GuideMap.nearest(game, human, Target.FAILLE, 4))
	for level: int in [1, 2, 3]:
		var map := game.levels[level]
		for y: int in map.height:
			for x: int in map.width:
				human.add_revealed_cell(level, GridPosition.new(x, y))
	assert_eq([human.base_x, human.base_y], [8, 10])
	assert_eq(str(GuideMap.nearest(game, human, Target.FAILLE, 1)), "GuideTarget(map, GridPosition(2, 6) on 1)")
	assert_eq(str(GuideMap.nearest(game, human, Target.CHEMINEE, 2)), "GuideTarget(map, GridPosition(0, 8) on 2)")
	assert_eq(str(GuideMap.nearest(game, human, Target.KERNEL, 3)), "GuideTarget(map, GridPosition(10, 10) on 3)")
	assert_null(GuideMap.nearest(game, human, Target.FAILLE, 2))
	assert_null(GuideMap.held_post_on(game, human, 1))
	assert_null(GuideMap.held_kernel(game, human))
	var bases: Array[TransitionBase] = []
	for cell: MapCell in game.levels[2].cells:
		if cell.transition_base != null:
			bases.append(cell.transition_base)
	assert_eq(str(GuideMap.post_cell(game, bases[-1])), "GuideTarget(map, GridPosition(0, 8) on 2)")
	assert_null(GuideMap.post_cell(game, TransitionBase.new(TransitionBaseType.Value.FAILLE, "X")))
	_first_base(game, 1).captured_by = human.id
	assert_eq(str(GuideMap.held_post_on(game, human, 1)), "GuideTarget(map, GridPosition(9, 1) on 1)")
	assert_null(GuideMap.held_post_on(game, human, 4))
	assert_eq(str(GuideMap.nearest(game, human, Target.FAILLE, 1)), "GuideTarget(map, GridPosition(2, 6) on 1)")
	var cells := game.levels[3].cells
	for index: int in cells.size():
		if cells[index].content == CellContentType.Value.VOLCANIC_KERNEL:
			cells[index] = cells[index].copy_with({"collected_by": human.id})
	var kernel := GuideMap.held_kernel(game, human)
	assert_eq(str(kernel), "GuideTarget(map, GridPosition(10, 10) on 3)")
	assert_true(kernel.garrison)
	assert_null(GuideMap.nearest(game, human, Target.KERNEL, 3))


func test_the_nearest_post_ties_by_row_then_column() -> void:
	var game := ObjectiveSamples.objective_game()
	for at: Vector2i in [Vector2i(7, 5), Vector2i(5, 7), Vector2i(3, 5), Vector2i(5, 3), Vector2i(9, 9)]:
		var base := TransitionBase.new(TransitionBaseType.Value.FAILLE, "X")
		var cell := MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.TRANSITION_BASE, null, null, base)
		game.levels[1].set_cell(at.x, at.y, cell)
		game.human_player().add_revealed_cell(1, GridPosition.of_key(at))
	var human := game.human_player()
	assert_eq(str(GuideMap.nearest(game, human, Target.FAILLE, 1)), "GuideTarget(map, GridPosition(5, 3) on 1)")
	game.levels[1].cell_at(5, 3).transition_base.captured_by = "x"
	assert_eq(str(GuideMap.nearest(game, human, Target.FAILLE, 1)), "GuideTarget(map, GridPosition(3, 5) on 1)")
	game.levels[1].cell_at(3, 5).transition_base.captured_by = "x"
	assert_eq(str(GuideMap.nearest(game, human, Target.FAILLE, 1)), "GuideTarget(map, GridPosition(7, 5) on 1)")


func _first_base(game: Game, level: int) -> TransitionBase:
	for cell: MapCell in game.levels[level].cells:
		if cell.transition_base != null:
			return cell.transition_base
	return null

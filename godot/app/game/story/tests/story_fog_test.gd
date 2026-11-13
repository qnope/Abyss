extends StoryCase
## lib/presentation/screens/game/story/turn_story_fog.dart: the fog chapter, on
## the level where the scouts saw the most.


func test_a_turn_that_showed_nothing_has_no_fog_chapter() -> void:
	assert_null(StoryFog.chapter(game, TurnStorySnapshot.of(human)))


func test_the_fog_lifts_on_the_level_where_the_most_cells_were_seen() -> void:
	var before := TurnStorySnapshot.of(human)
	see(1, hidden())
	see(2, Vector2i(1, 1))
	see(2, Vector2i(1, 2))
	var chapter := StoryFog.chapter(game, before)
	assert_true(chapter.is_fog())
	assert_eq(chapter.level, 2)
	assert_eq(chapter.seen, [Vector2i(1, 1), Vector2i(1, 2)] as Array[Vector2i])


func test_a_tie_goes_to_the_first_level() -> void:
	var before := TurnStorySnapshot.of(human)
	see(2, Vector2i(1, 1))
	see(1, hidden())
	assert_eq(StoryFog.chapter(game, before).level, 1)


func test_the_scouts_that_leave_are_those_whose_cell_was_seen() -> void:
	var first := hidden()
	var second := hidden(1)
	var elsewhere := hidden(2)
	for cell: Vector2i in [first, second, elsewhere]:
		human.pending_explorations.append(ExplorationOrder.new(GridPosition.new(cell.x, cell.y), 1))
	var before := TurnStorySnapshot.of(human)
	human.pending_explorations.clear()
	see(1, first)
	see(1, second)
	var chapter := StoryFog.chapter(game, before)
	assert_eq(chapter.scouts, [first, second] as Array[Vector2i], "the scout of a cell not seen is not here")

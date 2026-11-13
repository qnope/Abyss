extends StoryCase
## lib/presentation/screens/game/story/turn_story_snapshot.dart: what the
## player had seen and sent exploring before the turn.


func test_it_remembers_the_cells_seen_on_each_level() -> void:
	see(2, Vector2i(4, 4))
	var snapshot := TurnStorySnapshot.of(human)
	assert_eq(snapshot.revealed[2].keys(), [Vector2i(4, 4)])
	assert_eq(snapshot.revealed[1].size(), human.revealed_cells_on_level(1).size())


func test_a_cell_seen_since_is_newly_seen_in_the_order_it_was_seen() -> void:
	var snapshot := TurnStorySnapshot.of(human)
	assert_eq(snapshot.newly_seen(human, 1), [] as Array[Vector2i])
	see(1, hidden())
	var second := hidden()
	see(1, second)
	assert_eq(snapshot.newly_seen(human, 1).size(), 2)
	assert_eq(snapshot.newly_seen(human, 1)[1], second)


func test_every_cell_of_a_level_not_seen_before_is_new() -> void:
	var snapshot := TurnStorySnapshot.of(human)
	see(2, Vector2i(1, 1))
	assert_eq(snapshot.newly_seen(human, 2), [Vector2i(1, 1)] as Array[Vector2i])


func test_a_scout_that_waited_and_waits_no_more_is_gone() -> void:
	human.pending_explorations.append(ExplorationOrder.new(GridPosition.new(5, 6), 1))
	human.pending_explorations.append(ExplorationOrder.new(GridPosition.new(2, 2), 2))
	var snapshot := TurnStorySnapshot.of(human)
	assert_eq(snapshot.scouts_gone(human, 1), [] as Array[Vector2i])
	human.pending_explorations.remove_at(0)
	assert_eq(snapshot.scouts_gone(human, 1), [Vector2i(5, 6)] as Array[Vector2i])
	assert_eq(snapshot.scouts_gone(human, 2), [] as Array[Vector2i], "the other level's scout still waits")

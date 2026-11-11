extends TestCase
## test/domain/map/exploration_volcano_test.dart: a scout that sees a corner
## of the volcano sees all of it.


func test_a_scout_seeing_a_corner_of_the_volcano_reveals_all_of_it() -> void:
	var map := MapGenerator.generate(5, 3).map
	var orders: Array[ExplorationOrder] = [ExplorationOrder.new(GridPosition.new(12, 12), 3)]
	var player := Player.new("p", null, 0, 0, null, null, null, null, [], orders)
	var game := Game.new(player.id, {player.id: player}, 1, null, {3: map})
	ExplorationResolver.resolve(game)
	assert_has(player.revealed_cells_set_on_level(3), Vector2i(10, 10))
	assert_eq(map.cell_at(10, 10).content, CellContentType.Value.VOLCANIC_KERNEL)

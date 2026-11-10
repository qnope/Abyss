extends TestCase
## test/domain/fight/assault/assault_target_test.dart, its last three tests:
## the target an assault finds on a cell of a game (AssaultTarget.at).

const FAILLE := TransitionBaseType.Value.FAILLE
const CHEMINEE := TransitionBaseType.Value.CHEMINEE
const KERNEL := CellContentType.Value.VOLCANIC_KERNEL
const KERNEL_PART := CellContentType.Value.VOLCANIC_KERNEL_PART


func test_reads_an_uncaptured_faille_or_cheminee_on_the_map() -> void:
	var game := _game_with({
		0: _base(FAILLE), 1: _base(CHEMINEE), 2: _base(FAILLE, "p1"),
	})
	assert_eq(AssaultTarget.at(game, 1, 0, 0), AssaultTarget.Value.FAILLE)
	assert_eq(AssaultTarget.at(game, 1, 1, 0), AssaultTarget.Value.CHEMINEE)
	assert_null(AssaultTarget.at(game, 1, 2, 0))
	assert_null(AssaultTarget.at(game, 1, 3, 0))


func test_reads_the_kernel_from_any_cell_of_the_volcano() -> void:
	var game := _game_with({
		5: _kernel(KERNEL), 6: _kernel(KERNEL_PART),
		9: _kernel(KERNEL_PART), 10: _kernel(KERNEL_PART),
	})
	assert_eq(AssaultTarget.at(game, 1, 1, 1), AssaultTarget.Value.KERNEL)
	assert_eq(AssaultTarget.at(game, 1, 2, 2), AssaultTarget.Value.KERNEL)


func test_none_on_a_captured_kernel_an_unknown_level_or_a_bare_cell() -> void:
	var game := _game_with({5: _kernel(KERNEL, "p1")})
	assert_null(AssaultTarget.at(game, 1, 1, 1))
	assert_null(AssaultTarget.at(game, 2, 1, 1))


func _game_with(special: Dictionary[int, MapCell]) -> Game:
	var cells: Array[MapCell] = []
	for i: int in 16:
		cells.append(special.get(i, MapCell.new(TerrainType.Value.PLAIN)))
	var player := Player.new("Test", "p1")
	var levels: Dictionary[int, GameMap] = {1: GameMap.new(4, 4, cells, 1)}
	return Game.new(player.id, {player.id: player}, 1, levels)


func _base(type: TransitionBaseType.Value, captured_by: Variant = null) -> MapCell:
	return MapCell.new(
		TerrainType.Value.PLAIN, CellContentType.Value.TRANSITION_BASE, null, null,
		TransitionBase.new(type, "x", captured_by),
	)


func _kernel(content: CellContentType.Value, by: Variant = null) -> MapCell:
	return MapCell.new(TerrainType.Value.PLAIN, content, null, by)

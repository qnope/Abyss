extends TestCase
## test/domain/resource/pearl_income_test.dart. Its tests of the end of
## turn ('end of turn credits the pearls', 'end of turn caps pearls at max
## storage') wait for the turn module (TurnResolver).

const FAILLE := TransitionBaseType.Value.FAILLE
const CHEMINEE := TransitionBaseType.Value.CHEMINEE


func test_pearl_income_is_zero_without_captured_bases() -> void:
	var game := _game({1: _map([_base(FAILLE)])})
	assert_eq(PearlIncome.of(game, "p"), 0)
	assert_eq(PearlIncome.as_production(game, "p"), {} as Dictionary[ResourceType.Value, int])


func test_pearl_income_sums_captured_bases_across_levels() -> void:
	var game := _game({
		1: _map([_base(FAILLE, "p"), _base(FAILLE, "p"), _base(FAILLE, "other")]),
		2: _map([_base(CHEMINEE, "p")]),
	})
	assert_eq(PearlIncome.of(game, "p"), 2 + 2 + 3)
	assert_eq(
		PearlIncome.as_production(game, "p"),
		{ResourceType.Value.PEARL: 7} as Dictionary[ResourceType.Value, int],
	)


func _base(type: TransitionBaseType.Value, owner: Variant = null) -> TransitionBase:
	return TransitionBase.new(type, DartEnum.name_of(TransitionBaseType.Value, type), owner)


func _map(bases: Array[TransitionBase]) -> GameMap:
	var cells: Array[MapCell] = []
	for base: TransitionBase in bases:
		cells.append(MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.TRANSITION_BASE, null, null, base))
	cells.append_array(MapSamples.plain_cells(9 - bases.size()))
	return GameMap.new(3, 3, cells, 1)


func _game(levels: Dictionary[int, GameMap]) -> Game:
	var player := Player.new("p", "p", 1, 1)
	return Game.new("p", {"p": player}, 1, levels)

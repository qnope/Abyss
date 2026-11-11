extends TestCase
## test/domain/script/strategies/scout_moves_test.dart: where the scouts of
## the conquest look, level by level.


## The faction's scouts on level 3, around (13, 13) of a 32-cell map:
## between the old hard-coded centre (10, 10) and the volcano (16, 16).
func _on_the_volcano_level(scouts := 1) -> DeepScouts:
	var deep := DeepScouts.new()
	deep.put(3, scouts)
	deep.reveal(3, GridPosition.new(13, 13))
	return deep


func _none(_p: GridPosition) -> float:
	return 0.0


func test_from_centre_measures_from_the_middle_of_the_level_map() -> void:
	var turn := DeepScouts.new().turn()
	assert_eq(turn.game.levels[3].width, 32)
	assert_eq(ScoutMoves.from_centre(turn, 3, GridPosition.new(16, 16)), 0)
	assert_eq(ScoutMoves.from_centre(turn, 3, GridPosition.new(10, 10)), 6)


func test_from_centre_keeps_10_10_on_a_20_cell_map() -> void:
	var turn := DeepScouts.new(2).turn()
	assert_eq(ScoutMoves.from_centre(turn, 1, GridPosition.new(10, 10)), 0)
	assert_eq(ScoutMoves.from_centre(turn, 1, GridPosition.new(0, 3)), 10)


func test_kernel_seen_is_false_while_the_fog_hides_the_volcano() -> void:
	assert_false(ExpeditionMoves.kernel_seen(DeepScouts.new().turn()))


func test_kernel_seen_is_true_once_a_cell_of_it_is_revealed_held_or_not() -> void:
	var deep := DeepScouts.new()
	var at := deep.kernel()[0]
	deep.faction().add_revealed_cell(3, at)
	assert_true(ExpeditionMoves.kernel_seen(deep.turn()))

	var map := deep.game.levels[3]
	map.set_cell(at.x, at.y, map.cell_at(at.x, at.y).copy_with({"collected_by": "x"}))
	assert_null(ExpeditionMoves.open_kernel(deep.turn()))
	assert_true(ExpeditionMoves.kernel_seen(deep.turn()))


func test_level_3_the_scouts_head_for_the_real_centre_of_the_map() -> void:
	var deep := _on_the_volcano_level()
	ScoutMoves.scout(deep.turn(), 2)

	assert_eq(deep.targets(3).size(), 1)
	var target := deep.targets(3)[0]
	assert_true(target.x + target.y > 26)


func test_level_3_a_held_kernel_already_seen_no_longer_pulls_them() -> void:
	var deep := _on_the_volcano_level()
	var twin := _on_the_volcano_level()
	for d: DeepScouts in [deep, twin]:
		for at: GridPosition in d.kernel():
			d.faction().add_revealed_cell(3, at)
			var map := d.game.levels[3]
			map.set_cell(at.x, at.y, map.cell_at(at.x, at.y).copy_with({"collected_by": "someone"}))
	ScoutMoves.scout(deep.turn(), 2)
	ExploreMoves.explore(twin.turn(), 3, 2, _none)

	assert_eq(GridPosition.keys(deep.targets(3)), GridPosition.keys(twin.targets(3)))


func test_level_3_two_explorations_a_turn_by_default() -> void:
	var deep := _on_the_volcano_level(5)
	ScoutMoves.scout(deep.turn(), 2)
	assert_eq(deep.targets(3).size(), 2)


func test_level_3_deep_explorers_sets_the_explorations_on_levels_2_and_3() -> void:
	var deep := _on_the_volcano_level(5)
	deep.put(2, 5)
	deep.reveal(2, GridPosition.new(5, 5))
	ScoutMoves.scout(deep.turn(), 2, ConquestMoves.EXPEDITION_SCOUTS, 3)
	assert_eq(deep.targets(3).size(), 3)
	assert_eq(deep.targets(2).size(), 3)


## Not in the Dart file: scouts recruited for the base level, a bias of the
## caller, a Faille found that stops steering them, and a level without map.
func test_the_base_level_recruits_its_explorers_and_follows_a_bias() -> void:
	var deep := _without_faille()
	var toward_origin := func(_turn: ScriptTurn, p: GridPosition) -> float: return -10.0 * (p.x + p.y)
	ScoutMoves.scout(deep.turn(), 2, ConquestMoves.EXPEDITION_SCOUTS, 2, false, toward_origin)
	assert_eq(deep.scouts(1) + deep.targets(1).size(), 2)
	var base := deep.faction()
	for target: GridPosition in deep.targets(1):
		assert_true(target.x + target.y < base.base_x + base.base_y)
	var game := deep.game
	game.levels.erase(3)
	assert_eq(ScoutMoves.from_centre(deep.turn(), 3, GridPosition.new(10, 12)), 2)
	assert_false(ExpeditionMoves.kernel_seen(deep.turn()))
	assert_eq(ConquestMoves.ASSAULT_MIXES.size(), 3)


## Not in the Dart file: until a Faille is seen, the base level looks away
## from the middle of the map by default.
func test_by_default_the_base_level_looks_away_from_the_middle() -> void:
	var plain := _without_faille()
	var twin := _without_faille()
	var away := func(turn: ScriptTurn, p: GridPosition) -> float: return 0.3 * ScoutMoves.from_centre(turn, 1, p)
	ScoutMoves.scout(plain.turn(), 2)
	ScoutMoves.scout(twin.turn(), 2, ConquestMoves.EXPEDITION_SCOUTS, 2, false, away)
	assert_eq(plain.targets(1).size(), 2)
	assert_eq(GridPosition.keys(plain.targets(1)), GridPosition.keys(twin.targets(1)))


## A faction that sees no Faille it could take, its barracks built.
func _without_faille() -> DeepScouts:
	var deep := DeepScouts.new()
	deep.faction().buildings[BuildingType.Value.BARRACKS].level = 1
	for cell: MapCell in deep.game.levels[1].cells:
		if cell.transition_base != null:
			cell.transition_base.captured_by = "someone"
	return deep

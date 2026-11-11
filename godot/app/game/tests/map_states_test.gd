extends TestCase
## What the map of a level shows, read from a game of three levels against
## two factions (buildMapTab and factionBaseColors, kernelOwnerColors of
## lib/presentation/widgets/faction/faction_base_colors.dart).

var _game: Game
var _human: Player


func before_each() -> void:
	_game = GameFactory.new_game("Nemo", 1, Difficulty.Value.NORMAL, false, 2, null, "me")
	_human = _game.human_player()


func test_holds_the_cells_seen_of_the_level() -> void:
	var state := MapStates.of(_game, 1)
	assert_eq(state.level, 1)
	assert_eq(state.map, _game.levels[1])
	assert_eq(state.human_id, "me")
	assert_eq(state.revealed, _human.revealed_cells_set_on_level(1))
	assert_true(MapStates.of(_game, 2).revealed.is_empty())


func test_stands_the_base_and_the_rival_bases_on_the_first_level_only() -> void:
	var state := MapStates.of(_game, 1)
	assert_eq(state.base, Vector2i(_human.base_x, _human.base_y))
	assert_eq(state.faction_bases.size(), 2)
	for faction in _game.factions():
		var player: Player = _game.players[faction.id()]
		var at := Vector2i(player.base_x, player.base_y)
		assert_eq(state.faction_bases[at], FactionColors.of(faction.personality))
	var deeper := MapStates.of(_game, 2)
	assert_null(deeper.base)
	assert_true(deeper.faction_bases.is_empty())


func test_colours_whoever_can_hold_the_volcano() -> void:
	var owners := MapStates.of(_game, 3).owner_colors
	assert_eq(owners.size(), 3)
	assert_eq(owners["me"], AbyssColors.BIOLUM_CYAN)
	for faction in _game.factions():
		assert_eq(owners[faction.id()], FactionColors.of(faction.personality))


func test_tells_who_holds_the_post_above_each_passage() -> void:
	assert_true(MapStates.of(_game, 1).passage_holders.is_empty())
	var holders := MapStates.of(_game, 2).passage_holders
	assert_false(holders.is_empty())
	for holder: PostHolder.Value in holders.values():
		assert_eq(holder, PostHolder.Value.GUARDIANS)


func test_a_scout_sets_off_from_the_base_on_the_first_level() -> void:
	_human.pending_explorations.append(ExplorationOrder.new(GridPosition.new(3, 4), 1))
	_human.pending_explorations.append(ExplorationOrder.new(GridPosition.new(5, 6), 2))
	var state := MapStates.of(_game, 1)
	assert_eq(state.pending, {Vector2i(3, 4): Vector2i(_human.base_x, _human.base_y)})


func test_a_scout_deeper_sets_off_from_the_nearest_cell_seen() -> void:
	_human.add_revealed_cell(2, GridPosition.new(10, 10))
	_human.add_revealed_cell(2, GridPosition.new(20, 20))
	_human.pending_explorations.append(ExplorationOrder.new(GridPosition.new(12, 11), 2))
	assert_eq(MapStates.of(_game, 2).pending, {Vector2i(12, 11): Vector2i(10, 10)})

extends TestCase
## test/domain/faction/faction_play_test.dart: the factions playing inside
## the ends of turn (FactionGames). '3 factions play 60 turns and every one
## of them grows' (and 10) plays whole games too long for the suite.


func test_the_factions_play_after_the_human_in_a_fixed_order_and_are_journalled() -> void:
	var game := FactionGames.play(3, 3)
	var ids: Array[String] = []
	for f: Faction in game.factions():
		ids.append(f.id())
	var actors: Array = game.replay.actions_of(1).map(func(a: Dictionary) -> Variant: return a.get("player"))

	var first_faction := actors.find_custom(func(a: Variant) -> bool: return a != null)
	assert_true(first_faction > 0)
	assert_true(actors.slice(0, first_faction).all(func(a: Variant) -> bool: return a == null))
	var order := actors.filter(func(a: Variant) -> bool: return a != null)
	var firsts: Array[int] = []
	for id: String in ids:
		assert_has(order, id)
		firsts.append(order.find(id))
	var sorted := firsts.duplicate()
	sorted.sort()
	assert_eq(firsts, sorted)
	assert_true(game.replay.exact)


func test_the_switch_off_leaves_the_factions_idle() -> void:
	var game := FactionGames.play(3, 1)
	var snapshot := _growths(game)

	ActionExecutor.new().execute(EndTurnAction.new(null, false), game, game.human_player())

	assert_eq(game.turn, 2)
	assert_eq(_growths(game), snapshot)
	assert_eq(game.replay.actions_of(1).filter(func(a: Dictionary) -> bool: return a.has("player")), [])


func test_a_faction_that_lost_3_raids_in_a_row_falls_and_stops_playing() -> void:
	var game := FactionGames.play(2, 5)
	var victim: Player = game.players[game.factions()[0].id()]
	var other: Player = game.players[game.factions()[-1].id()]
	var post := _first_transition_base(game)
	post.captured_by = victim.id
	victim.raid_state.lost_in_a_row = 3
	var fall_turn := game.turn

	ActionExecutor.new().execute(EndTurnAction.new(), game, game.human_player())
	var victim_growth := FactionGames.growth_of(victim)
	var other_growth := FactionGames.growth_of(other)
	for _i: int in 10:
		ActionExecutor.new().execute(EndTurnAction.new(), game, game.human_player())

	assert_true(victim.has_fallen())
	assert_false(other.has_fallen())
	assert_eq(game.status, GameStatus.Value.PLAYING, "only the human can lose")
	assert_null(post.captured_by)
	assert_eq(FactionGames.growth_of(victim), victim_growth)
	assert_true(FactionGames.growth_of(other) > other_growth)
	for t: int in range(fall_turn + 1, game.turn):
		assert_eq(game.replay.actions_of(t).filter(func(a: Dictionary) -> bool: return a.get("player") == victim.id), [])


static func _growths(game: Game) -> Array[int]:
	var growths: Array[int] = []
	for f: Faction in game.factions():
		growths.append(FactionGames.growth_of(game.players[f.id()]))
	return growths


static func _first_transition_base(game: Game) -> TransitionBase:
	for map: GameMap in game.levels.values():
		for cell: MapCell in map.cells:
			if cell.transition_base != null:
				return cell.transition_base
	return null

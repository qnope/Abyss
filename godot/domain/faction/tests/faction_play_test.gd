extends TestCase
## test/domain/faction/faction_play_test.dart: the factions playing inside
## the ends of turn (FactionGames). Its checks of the replay journal
## (`game.replay.actionsOf`) wait for `ActionEncoder`: 'the factions play
## after the human, in a fixed order, and are journalled' altogether, the
## last check of the two tests here. '3 factions play 60 turns and every one
## of them grows' (and 10) plays whole games too long for the suite.


func test_the_switch_off_leaves_the_factions_idle() -> void:
	var game := FactionGames.play(3, 1)
	var snapshot := _growths(game)

	ActionExecutor.new().execute(EndTurnAction.new(null, false), game, game.human_player())

	assert_eq(game.turn, 2)
	assert_eq(_growths(game), snapshot)


func test_a_faction_that_lost_3_raids_in_a_row_falls_and_stops_playing() -> void:
	var game := FactionGames.play(2, 5)
	var victim: Player = game.players[game.factions()[0].id()]
	var other: Player = game.players[game.factions()[-1].id()]
	var post := _first_transition_base(game)
	post.captured_by = victim.id
	victim.raid_state.lost_in_a_row = 3

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

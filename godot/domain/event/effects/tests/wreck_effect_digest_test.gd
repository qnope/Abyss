extends TestCase
## Not in the Dart files: the wreck sites of generated games and where the
## wreck sinks, player after player, as the Dart rules printed them (a
## scratch script on GameFactory games: the sites of level 1, the first and
## the last, the cell drawn with Random(sites + 12) at the end of turn 12,
## and the next nextInt(1000) of those dice).

const HUMAN_ID := "00000000-0000-4000-8000-000000000000"

## [sites, first, last, cell drawn, next roll], player after player.
const SOLO := {
	1: [[18, Vector2i(11, 7), Vector2i(14, 13), Vector2i(9, 9), 682]],
	3: [[22, Vector2i(6, 6), Vector2i(12, 12), Vector2i(6, 6), 953]],
	7: [[22, Vector2i(5, 7), Vector2i(11, 13), Vector2i(5, 7), 953]],
	11: [[21, Vector2i(5, 7), Vector2i(11, 13), Vector2i(6, 13), 231]],
	24: [[18, Vector2i(7, 8), Vector2i(12, 14), Vector2i(13, 9), 682]],
	42: [[20, Vector2i(7, 8), Vector2i(12, 14), Vector2i(9, 8), 331]],
}
const WITH_FACTIONS := {
	5: [
		[21, Vector2i(8, 5), Vector2i(13, 11), Vector2i(14, 10), 231],
		[23, Vector2i(13, 13), Vector2i(19, 19), Vector2i(16, 13), 727],
		[20, Vector2i(0, 7), Vector2i(6, 13), Vector2i(2, 7), 331],
	],
	29: [
		[19, Vector2i(9, 9), Vector2i(14, 15), Vector2i(15, 10), 549],
		[21, Vector2i(0, 12), Vector2i(6, 18), Vector2i(6, 17), 231],
		[21, Vector2i(1, 3), Vector2i(6, 9), Vector2i(1, 9), 231],
	],
}


func test_sinks_the_wreck_of_a_single_player_game_as_dart_does() -> void:
	for seed_value: int in SOLO:
		_assert_digest(GameFactory.new_single_player("h", seed_value), SOLO[seed_value], seed_value)


func test_sinks_the_wreck_of_each_player_of_a_game_with_factions_as_dart_does() -> void:
	for seed_value: int in WITH_FACTIONS:
		var game := GameFactory.new_game("h", seed_value, Difficulty.Value.NORMAL, false, 2, null, HUMAN_ID)
		_assert_digest(game, WITH_FACTIONS[seed_value], seed_value)


func _assert_digest(game: Game, expected: Variant, seed_value: int) -> void:
	var effect := WreckEffect.new()
	var found := []
	var map: GameMap = game.levels[1]
	for player: Player in game.players.values():
		var sites := WreckSites.of(map, player)
		var draw := DartRandom.new(sites.size() + 12)
		assert_true(effect.allowed_at(game, player, 12))
		effect.on_draw(game, player, 12, draw)
		var at := player.event_state.wreck_position
		assert_eq(map.cell_at(at.x, at.y).content, CellContentType.Value.WRECK)
		assert_eq(player.event_state.wreck_until_turn, 17)
		assert_false(effect.allowed_at(game, player, 13))
		found.append([sites.size(), sites[0].key(), sites[-1].key(), at.key(), draw.next_int(1000)])
	assert_eq(found, expected, "seed %d" % seed_value)

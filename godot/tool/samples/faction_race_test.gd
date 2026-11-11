extends TestCase
## FactionRace, on a few turns: the whole race is a long case of
## tool/replay (FactionRaceCases).


func test_plays_the_lone_faction_up_to_the_limit_the_human_kept_playing() -> void:
	var game := FactionRace.play_lone_faction(FactionPersonality.Value.MAGMA_SMITHS, 1, 4)

	assert_eq(game.turn, 4)
	assert_eq(game.status, GameStatus.Value.PLAYING)
	assert_eq(game.factions().size(), 1)
	assert_eq(game.factions()[0].personality, FactionPersonality.Value.MAGMA_SMITHS)
	assert_null(VictoryChecker.winner_of(game))

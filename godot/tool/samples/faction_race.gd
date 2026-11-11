class_name FactionRace
extends RefCounted
## The twin of test/helpers/faction_race.dart.


## `playLoneFaction`: the game of a human who does nothing against one
## faction of `personality` left alone to run for the volcano, played until
## the faction wins or `limit` turns.
##
## The idle human would fall to the raids long before the faction could
## finish, so a defeat that is not the faction's is taken back: only the
## race is looked at.
static func play_lone_faction(personality: FactionPersonality.Value, seed_: int, limit := 220) -> Game:
	var seeds := DartRandom.new(seed_, false)
	var personalities: Array[FactionPersonality.Value] = [personality]
	var game := GameFactory.new_game(
		"Nemo", seeds.next_int(0x7FFFFFFF), Difficulty.Value.NORMAL, false, 0, personalities
	)
	var executor := ActionExecutor.new()
	while game.turn < limit:
		executor.execute(EndTurnAction.new(DartRandom.new(seeds.next_int(1 << 30))), game, game.human_player())
		if VictoryChecker.winner_of(game) != null:
			break
		game.status = GameStatus.Value.PLAYING
	return game

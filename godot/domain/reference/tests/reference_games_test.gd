extends TestCase
## Not in the Dart files: the games of reference/games/, which Dart wrote,
## as Godot reads them (CommittedGame). Every section of the state each
## replay starts from (reference/README.md, "Replaying it", step 1) has
## the digest of the first entry of `turns`. The turns after it wait for
## the codec of the actions, which decodes the journal.

var games := CommittedGame.all()


func test_reads_every_game_of_the_set() -> void:
	assert_eq(games.size(), 19)
	assert_eq(games[0].name, "balanced-normal-2-factions")
	for game: CommittedGame in games:
		assert_eq(game.sections(), PackedStringArray(SnapshotSections.names()), game.name)
		assert_eq(game.turns()[0], 1, game.name)
		assert_eq(game.turn_digests().size(), game.turns().size(), game.name)
		for row: PackedStringArray in game.turn_digests():
			assert_false(row.has(DigestRows.SAME), game.name)
		assert_eq(game.final_digests().size(), 20, game.name)


func test_tells_how_a_game_ended() -> void:
	var game := games[games.find_custom(func(g: CommittedGame) -> bool: return g.name == "conquest-normal")]
	assert_eq([game.status(), game.turn()], ["victory", 90])
	assert_eq(game.journal()["player"], "conquest")


func test_every_game_starts_in_the_state_dart_started_it_in() -> void:
	for game: CommittedGame in games:
		var digests := GameSnapshot.digests(game.starting_game(), Sha256Hex.of)
		var first := game.turn_digests()[0]
		for i: int in first.size():
			assert_eq(digests[i], first[i], "%s: %s" % [game.name, game.sections()[i]])


func test_a_game_against_factions_starts_with_them_in_their_order() -> void:
	var game := games[games.find_custom(func(g: CommittedGame) -> bool: return g.name == "conquest-hard-3-factions")]
	var started := game.starting_game()
	assert_eq(started.human_player_id, CommittedGame.HUMAN_ID)
	assert_eq(started.players.keys(), [
		CommittedGame.HUMAN_ID, "faction-silenceMonks", "faction-wreckPillagers", "faction-anglerCult",
	])
	assert_eq(started.difficulty(), Difficulty.Value.HARD)

extends TestCase
## Not in the Dart tests: every move of the journal of every game of
## `reference/games/` is read by ActionCodec as the action Dart played,
## which ActionEncoder writes back as the journal holds it, its seed and
## its army in their order. Replaying the games, every digest of every turn
## compared, is the work of `tool/godot_reference.sh` (tool/replay/), too
## slow for the unit tests but for the short ones (reference_replay_test).


func test_every_move_of_every_reference_journal_round_trips_through_the_codec() -> void:
	var moves := 0
	for game: CommittedGame in CommittedGame.all():
		var turns: Dictionary = ReplayJournal.whole_numbers(game.journal()["turns"])
		for turn: String in turns:
			for move: Dictionary in turns[turn]:
				moves += 1
				var spec := ActionCodec.decode(move)
				var seed_: int = move.get("seed", 0)
				var random := DartRandom.new(seed_, move.has("seed"))
				var action: Action = spec.call(random)
				var written: Dictionary = move.duplicate()
				written.erase("player")
				var encoded: Variant = ActionEncoder.encode(action, CommittedGame.HUMAN_ID)
				assert_eq(JSON.stringify(encoded, "", false), JSON.stringify(written, "", false), "%s turn %s" % [game.name, turn])
	assert_true(moves > 10000, str(moves))

extends TestCase
## Not in the Dart tests: the journal of every game of `reference/games/`,
## decoded by ActionCodec and replayed on a new game as Dart's
## `ReferenceExporter` does (JournalReplay), plays every action again, ends
## as the file's `result` says, and journals the very moves and seeds it
## replayed, which ReplayExport writes back as the file holds them. The
## digests of each turn are compared by the snapshots of `reference`.
##
## The two games against ten factions take 14 s of the 26 s these replays
## take: they have a test of their own.

const TEN_FACTIONS: Array[String] = ["conquest-normal-10-factions.json", "idle-normal-10-factions.json"]


func test_every_reference_journal_but_ten_factions_replays_to_its_result() -> void:
	var games := JournalReplay.reference_games()
	assert_true(games.size() > TEN_FACTIONS.size())
	for file: String in games:
		if file not in TEN_FACTIONS:
			_check(file)


func test_the_journals_against_ten_factions_replay_to_their_result() -> void:
	for file: String in TEN_FACTIONS:
		_check(file)


func _check(file: String) -> void:
	var reference := JournalReplay.read_game(file)
	var journal: Dictionary = ReplayJournal.whole_numbers(reference["journal"])
	var result: Dictionary = ReplayJournal.whole_numbers(reference["result"])
	var source: Dictionary = reference["source"]
	var replay := JournalReplay.new(journal, source)

	assert_eq(replay.refused, [] as Array[String], file)
	assert_eq(replay.unplayed, 0, file)
	assert_eq(DartEnum.name_of(GameStatus.Value, replay.game.status), result["status"], file)
	assert_eq(replay.game.turn, result["turn"], file)
	assert_eq(JSON.stringify(ReplayExport.to_json(replay.game), "", false), JSON.stringify(journal, "", false), file)

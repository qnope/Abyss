extends CodecTestCase
## JournalCodec: the journal of a game's moves, each move kept to the
## character, its turns in their order.


static func _journal() -> ReplayJournal:
	var first: Array[String] = ["{\"do\":\"upgrade\",\"building\":\"algaeFarm\"}", "{\"do\":\"x\",\"n\":2.5}"]
	var third: Array[String] = ["{\"do\":\"y\",\"player\":\"faction-pearlOrder\"}"]
	return ReplayJournal.new(1234567, "Nemo", {3: third, 1: first}, {1: 2147483646, 2: 0}, false)


func test_keeps_every_move_and_every_seed_in_their_order() -> void:
	var journal := _journal()
	var read: ReplayJournal = assert_round_trip(
		JournalSnapshots.journal(), JournalCodec.journal, JournalCodec.read_journal, journal)
	assert_eq(read.actions.keys(), [3, 1])
	assert_eq(read.actions[1], journal.actions[1])
	assert_eq(read.end_turn_seeds, journal.end_turn_seeds)
	assert_false(read.exact)
	assert_round_trip(JournalSnapshots.journal(), JournalCodec.journal, JournalCodec.read_journal,
		ReplayJournal.new(1, "A"))


func test_writes_the_turns_by_their_digits_and_the_moves_as_texts() -> void:
	var text := JSON.stringify(JournalCodec.journal(_journal()), "", false)
	assert_true(text.begins_with("{\"mapSeed\":1234567,\"playerName\":\"Nemo\",\"actions\":{\"3\":[\"{\\\"do\\\""), text)
	assert_true(text.ends_with("\"endTurnSeeds\":{\"1\":2147483646,\"2\":0},\"exact\":false}"), text)


func test_a_turn_or_a_move_of_the_wrong_type_is_a_problem() -> void:
	var text := JSON.stringify(JournalCodec.journal(_journal()), "", false)
	assert_eq(problem_of(JournalCodec.read_journal, text.replace("\"3\":", "\"three\":")),
		"actions: \"three\" is not a whole number")
	assert_eq(problem_of(JournalCodec.read_journal, text.replace("{\"1\":2147483646", "{\"01\":2147483646")),
		"endTurnSeeds: \"01\" is not a whole number")
	assert_eq(problem_of(JournalCodec.read_journal, text.replace("\"actions\":{\"3\":[", "\"actions\":{\"3\":[4,")),
		"actions is not a text")

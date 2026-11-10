extends TestCase
## test/domain/replay/replay_journal_test.dart: its three tests wait for
## `record` and the actions it notes (the action module), the last one is a
## Hive round-trip, which never comes. What follows is not in the Dart file:
## the journal as the actions will find it, and actions_of, which the
## snapshots and the exports read.


func test_a_new_journal_holds_no_move_and_is_exact() -> void:
	var journal := ReplayJournal.new(1, "Nemo")
	assert_eq([journal.map_seed, journal.player_name, journal.exact], [1, "Nemo", true])
	assert_eq(journal.actions, {} as Dictionary[int, Array])
	assert_eq(journal.end_turn_seeds, {} as Dictionary[int, int])
	assert_eq(journal.actions_of(1), [] as Array[Dictionary])


func test_takes_its_fields_in_the_dart_order() -> void:
	var actions: Dictionary[int, Array] = {2: _moves(['{"do":"unlock","branch":"explorer"}'])}
	var seeds: Dictionary[int, int] = {2: 8}
	var journal := ReplayJournal.new(5, "Nemo", actions, seeds, false)
	assert_eq([journal.actions, journal.end_turn_seeds, journal.exact], [actions, seeds, false])


func test_decodes_the_moves_of_a_turn_oldest_first() -> void:
	var journal := ReplayJournal.new(1, "Nemo")
	journal.actions[2] = _moves([
		'{"do":"recruit","unit":"scout","count":3}',
		'{"do":"upgrade","building":"headquarters","player":"faction-pearlOrder"}',
	])
	assert_eq(journal.actions_of(2), [
		{"do": "recruit", "unit": "scout", "count": 3},
		{"do": "upgrade", "building": "headquarters", "player": "faction-pearlOrder"},
	] as Array[Dictionary])
	assert_eq(journal.actions_of(3), [] as Array[Dictionary])


## Godot's JSON reads every number as a float; Dart's jsonDecode gives a
## whole number an int, which the journal holds alone.
func test_a_whole_number_decodes_as_an_int_at_any_depth() -> void:
	var journal := ReplayJournal.new(1, "Nemo")
	journal.actions[1] = _moves([
		'{"do":"fight","x":4,"units":{"guardian":12},"at":[2,3],"seed":2147483646,"go":true}',
	])
	var move: Dictionary = journal.actions_of(1)[0]
	assert_eq(move["x"], 4)
	assert_eq(move["units"], {"guardian": 12})
	assert_eq(move["at"], [2, 3])
	assert_eq(move["seed"], 2147483646)
	assert_eq(move["go"], true)
	assert_eq(ReplayJournal._whole_numbers(2.5), 2.5)


## The snapshots write a move as the pairs of its keys in the order the
## journal wrote them.
func test_keeps_the_keys_in_the_order_they_were_written() -> void:
	var journal := ReplayJournal.new(1, "Nemo")
	journal.actions[1] = _moves(['{"do":"fight","x":4,"y":1,"level":1,"player":"p"}'])
	assert_eq(journal.actions_of(1)[0].keys(), ["do", "x", "y", "level", "player"])


func _moves(texts: Array[String]) -> Array[String]:
	return texts

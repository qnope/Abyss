extends TestCase
## test/domain/script/faction_tally_test.dart. A journal is a list of
## `[turn, moves]`, Dart's records.


func test_counts_each_verb_per_player_a_move_without_player_is_human() -> void:
	var tally := FactionTally.new()
	tally.add_journal([
		[1, [_move("upgrade"), _move("upgrade", {"player": "f1"})]],
		[2, [_move("upgrade", {"player": "f1"})]],
	])

	assert_eq(tally.of("human", "upgrade"), 1)
	assert_eq(tally.of("f1", "upgrade"), 2)
	assert_eq(tally.of("f2", "upgrade"), 0)


func test_counts_explorations_and_collections_by_level_level_1_by_default() -> void:
	var tally := FactionTally.new()
	tally.add_journal([[1, [
		_move("explore", {"player": "f1"}),
		_move("explore", {"player": "f1", "level": 3}),
		_move("collect", {"player": "f1", "level": 2}),
	]]])

	assert_eq(tally.of("f1", "explore"), 2)
	assert_eq(tally.of("f1", "explore@1"), 1)
	assert_eq(tally.of("f1", "explore@3"), 1)
	assert_eq(tally.of("f1", "collect@2"), 1)


func test_counts_unlocks_and_research_by_branch() -> void:
	var tally := FactionTally.new()
	tally.add_journal([[1, [
		_move("unlock", {"player": "f1", "branch": "explorer"}),
		_move("research", {"player": "f1", "branch": "explorer"}),
		_move("research", {"player": "f1", "branch": "military"}),
	]]])

	assert_eq(tally.of("f1", "unlock:explorer"), 1)
	assert_eq(tally.of("f1", "research:explorer"), 1)
	assert_eq(tally.of("f1", "research:military"), 1)
	assert_eq(tally.of("f1", "research"), 2)


func test_counts_attacks_on_the_human_base_apart() -> void:
	var tally := FactionTally.new()
	tally.add_journal([[1, [
		_move("attackPlayer", {"player": "f1", "target": "human"}),
		_move("attackPlayer", {"player": "f1", "target": "f2"}),
	]]])

	assert_eq(tally.of("f1", "attackPlayer"), 2)
	assert_eq(tally.of("f1", "attackHuman"), 1)


func test_files_faction_held_kernel_attacks_under_the_kernel_level_of_their_turn() -> void:
	var tally := FactionTally.new()
	tally.kernel_level_at[2] = 7
	tally.add_journal([
		[1, [_move("attackHeldKernel", {"player": "f1"})]],
		[2, [
			_move("attackHeldKernel"),
			_move("attackHeldKernel", {"player": "f1"}),
			_move("attackHeldKernel", {"player": "f2"}),
		]],
	])

	assert_eq(tally.held_kernel_by_level, {0: 1, 7: 2})
	assert_eq(tally.of("human", "attackHeldKernel"), 1)


## Not in the Dart file: a research without branch is counted under
## `null`, as Dart writes it.
func test_a_move_without_branch_is_counted_under_null() -> void:
	var tally := FactionTally.new()
	tally.add_journal([[1, [_move("research")]]])

	assert_eq(tally.of("human", "research:null"), 1)


static func _move(verb: String, more := {}) -> Dictionary:
	var move := {"do": verb}
	move.merge(more)
	return move

extends TestCase
## test/domain/game/player_history_test.dart: the history a player keeps,
## the 100 latest entries.


func test_player_history_entries_new_player_has_empty_history() -> void:
	assert_eq(Player.new("p").history_entries.size(), 0)


func test_player_history_entries_add_history_entry_appends_a_single_entry() -> void:
	var player := Player.new("p")
	var entry := _entry(1)
	player.add_history_entry(entry)
	assert_eq(player.history_entries.size(), 1)
	assert_true(player.history_entries[0] == entry)


func test_player_history_entries_fifo_cap_drops_oldest_entries_when_exceeding_k_history_max_entries() -> void:
	var player := Player.new("p")
	for i: int in range(1, 151):
		player.add_history_entry(_entry(i))
	assert_eq(player.history_entries.size(), HistoryConstants.K_HISTORY_MAX_ENTRIES)
	# Oldest kept entry is turn 51 (entries 1..50 dropped).
	assert_eq(player.history_entries[0].turn, 51)
	# Newest entry is the last one added (turn 150).
	assert_eq(player.history_entries[-1].turn, 150)


func test_player_history_entries_order_is_oldest_first_newest_last() -> void:
	var player := Player.new("p")
	for i: int in range(1, 4):
		player.add_history_entry(_entry(i))
	assert_eq(player.history_entries[0].turn, 1)
	assert_eq(player.history_entries[1].turn, 2)
	assert_eq(player.history_entries[-1].turn, 3)


func test_player_history_entries_two_players_have_independent_history_lists() -> void:
	var a := Player.new("a")
	var b := Player.new("b")
	a.add_history_entry(_entry(1))
	assert_eq(a.history_entries.size(), 1)
	assert_eq(b.history_entries.size(), 0)


func _entry(turn: int) -> HistoryEntry:
	return BuildingEntry.new(turn, BuildingType.Value.ALGAE_FARM, turn)

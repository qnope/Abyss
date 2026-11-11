extends TestCase
## test/domain/game/save_sections_test.dart.

var old_run := _game("A", GameStatus.Value.PLAYING, DateSamples.at(2026, 1, 3))
var recent_run := _game("B", GameStatus.Value.PLAYING, DateSamples.at(2026, 2, 1))
var won := _game("C", GameStatus.Value.VICTORY, DateSamples.at(2026, 1, 1))
var free := _game("D", GameStatus.Value.FREE_PLAY, DateSamples.at(2026, 3, 1))
var lost := _game("E", GameStatus.Value.DEFEAT, DateSamples.at(2026, 2, 5))


static func _game(name: String, status: GameStatus.Value, last_played_at: int) -> Game:
	var player := Player.new(name)
	return Game.new(
		player.id, {player.id: player}, 1, DateSamples.at(2026, 1, 1), {}, status, null,
		Difficulty.Value.NORMAL, last_played_at,
	)


func test_no_save_gives_two_empty_sections_and_nothing_to_continue() -> void:
	var sections := SaveSections.of([])
	assert_eq(sections.in_progress, [] as Array[Game])
	assert_eq(sections.finished, [] as Array[Game])
	assert_true(sections.is_empty())
	assert_null(sections.most_recent_in_progress())


func test_games_still_played_are_in_progress_latest_played_first() -> void:
	var sections := SaveSections.of([old_run, won, recent_run, lost])
	assert_eq(sections.in_progress, [recent_run, old_run] as Array[Game])


func test_a_game_won_then_played_on_is_still_in_progress() -> void:
	var sections := SaveSections.of([won, old_run, lost, free, recent_run])
	assert_eq(sections.in_progress, [free, recent_run, old_run] as Array[Game])


func test_won_and_lost_games_are_finished_latest_played_first() -> void:
	var sections := SaveSections.of([won, old_run, lost, free, recent_run])
	assert_eq(sections.finished, [lost, won] as Array[Game])
	assert_false(sections.is_empty())


func test_the_game_to_continue_is_the_latest_played_in_progress() -> void:
	assert_true(SaveSections.of([old_run, recent_run]).most_recent_in_progress() == recent_run)


func test_a_game_in_free_play_can_be_continued() -> void:
	assert_true(SaveSections.of([old_run, free, recent_run]).most_recent_in_progress() == free)


func test_only_finished_games_leave_nothing_to_continue() -> void:
	assert_null(SaveSections.of([won, lost]).most_recent_in_progress())


func test_an_old_save_without_stamp_is_ordered_by_its_creation() -> void:
	var player := Player.new("Old")
	var legacy := Game.new(player.id, {player.id: player}, 1, DateSamples.at(2026, 1, 10))
	var sections := SaveSections.of([old_run, legacy])
	assert_eq(sections.in_progress, [legacy, old_run] as Array[Game])


func test_the_sections_cannot_be_changed_from_outside() -> void:
	var sections := SaveSections.of([old_run, won])
	expect_error("read-only")
	sections.in_progress.append(won)
	expect_error("read-only")
	sections.finished.clear()
	assert_eq(sections.in_progress, [old_run] as Array[Game])
	assert_eq(sections.finished, [won] as Array[Game])


func test_counts_every_save_in_progress_or_finished() -> void:
	assert_eq(SaveSections.of([old_run, won, lost]).count(), 3)
	assert_eq(SaveSections.of([]).count(), 0)

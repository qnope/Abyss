extends TestCase
## test/domain/turn/turn_resolver_defeat_test.dart: the raids lost in a row
## that end the game.


static func _wave() -> MonsterLair:
	return MonsterLair.new(MonsterDifficulty.Value.EASY, 5)


static func _game_with_raid_due(lost_in_a_row: int) -> Game:
	var player := Player.new("Human", "h", 5, 5)
	player.raid_state.lost_in_a_row = lost_in_a_row
	player.raid_state.announce(_wave(), 12)
	var game := Game.single_player(player)
	game.turn = 12
	return game


func test_losing_a_third_raid_in_a_row_ends_the_game() -> void:
	var game := _game_with_raid_due(2)
	var result := TurnResolver.new().resolve(game)
	assert_false(result.raid.victory)
	assert_eq(game.status, GameStatus.Value.DEFEAT)


func test_losing_a_second_raid_in_a_row_keeps_the_game_going() -> void:
	var game := _game_with_raid_due(1)
	TurnResolver.new().resolve(game)
	assert_eq(game.human_player().raid_state.lost_in_a_row, 2)
	assert_eq(game.status, GameStatus.Value.PLAYING)


func test_raid_outcomes_are_counted_for_the_statistics() -> void:
	var player := Player.new("Human", "h")
	player.raid_state.announce(_wave(), 12)
	RaidResolver.resolve(player, 12, DartRandom.new(1))
	player.raid_state.record_outcome(true)
	assert_eq(player.raid_state.raids_lost, 1)
	assert_eq(player.raid_state.raids_repelled, 1)
	assert_eq(player.raid_state.lost_in_a_row, 0)


## Not in the Dart file: a game already over stays as it is.
func test_a_game_already_won_stays_won() -> void:
	var game := _game_with_raid_due(2)
	game.status = GameStatus.Value.VICTORY
	TurnResolver.new().resolve(game)
	assert_eq(game.status, GameStatus.Value.VICTORY)

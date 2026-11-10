extends TestCase
## The sample players and games the tests of the domain share.

const KERNEL := BuildingType.Value.VOLCANIC_KERNEL


func test_a_player_is_named_after_its_id_and_holds_what_a_new_one_holds() -> void:
	var player := GameSamples.player("h")
	assert_eq([player.id, player.name], ["h", "h"])
	assert_eq(player.buildings.size(), 11)


func test_a_player_with_buildings_holds_only_those() -> void:
	var player := GameSamples.player_with("h", {KERNEL: 10})
	assert_eq(player.buildings.keys(), [KERNEL])
	assert_eq(player.buildings[KERNEL].level, 10)


func test_a_game_plays_the_first_player_as_the_human() -> void:
	var human := GameSamples.player("h")
	var rival := GameSamples.player("f")
	var game := GameSamples.game([human, rival], GameStatus.Value.FREE_PLAY)
	assert_eq(game.players.keys(), ["h", "f"])
	assert_true(game.human_player() == human)
	assert_eq([game.turn, game.status], [1, GameStatus.Value.FREE_PLAY])


func test_two_players_stand_half_a_map_apart() -> void:
	var game := GameSamples.two_players(3, "rival-id")
	var human := game.human_player()
	var rival: Player = game.players["rival-id"]
	assert_eq(game.players.keys(), [human.id, "rival-id"])
	assert_eq(human.name, "human")
	assert_eq(rival.name, "rival")
	assert_eq(rival.base_x, (human.base_x + 10) % 20)
	assert_eq(rival.base_y, (human.base_y + 10) % 20)
	assert_has(rival.revealed_cells(), Vector2i(rival.base_x, rival.base_y))
	assert_eq(GameSamples.two_players().players.size(), 2)

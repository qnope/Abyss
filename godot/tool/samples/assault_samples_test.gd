extends TestCase
## Not in the Dart files: the two-player game of the assaults and the
## helpers that set what stands on a base.


func test_the_assault_game_sees_the_rival_base_at_turn_12() -> void:
	var game := AssaultSamples.assault_game()
	var human := game.human_player()
	var rival := AssaultSamples.rival_of(game)
	assert_eq([game.turn, rival.id], [12, "rival-1"])
	assert_eq(Building.level_in(rival.buildings, BuildingType.Value.HEADQUARTERS), 5)
	assert_true(human.revealed_cells_set_on_level(1).has(Vector2i(rival.base_x, rival.base_y)))
	var blind := AssaultSamples.assault_game(3, false, "r")
	assert_eq([blind.turn, AssaultSamples.rival_of(blind).id], [3, "r"])
	assert_true(blind.human_player().revealed_cells_set_on_level(1).size() < human.revealed_cells_set_on_level(1).size())


func test_station_puts_exactly_the_units_given_on_the_base() -> void:
	var player := AssaultSamples.rival_of(AssaultSamples.assault_game())
	AssaultSamples.station(player, AssaultSamples.HORDE)
	assert_eq(player.unit_counts_on_level(1), AssaultSamples.HORDE)
	AssaultSamples.station(player, AssaultSamples.WALL)
	assert_eq(AssaultSamples.standing(player, UnitType.Value.HARPOONIST), 60)
	assert_eq(player.unit_counts_on_level(1), AssaultSamples.WALL)

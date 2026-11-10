extends TestCase
## Not in the Dart files: the samples the tests of the actions build.


func test_a_stocked_player_holds_only_the_stocks_and_buildings_given() -> void:
	var recruited: Array[UnitType.Value] = [UnitType.Value.SCOUT]
	var player := ActionSamples.stocked(
		ActionSamples.amounts(1, 2, 3, 4, 5), {BuildingType.Value.BARRACKS: 2}, recruited
	)
	assert_eq([player.id, player.name], ["test", "Test"])
	assert_eq(player.resources.keys(), ResourceType.Value.values())
	assert_eq(player.resources[ResourceType.Value.PEARL].amount, 5)
	assert_eq(player.buildings.keys(), [BuildingType.Value.BARRACKS])
	assert_eq(player.recruited_unit_types, recruited)


func test_the_game_of_a_player_alone_starts_at_the_turn_given() -> void:
	var player := GameSamples.player("p")
	var game := ActionSamples.game_of(player, 7)
	assert_eq([game.human_player_id, game.players.keys(), game.turn], ["p", ["p"], 7])

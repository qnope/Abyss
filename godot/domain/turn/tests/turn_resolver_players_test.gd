extends TestCase
## Not in the Dart files: the players a turn passes over and the attacks it
## reports, which the Dart tests reach through EndTurnAction.


func test_a_fallen_player_neither_produces_nor_draws() -> void:
	var human := Player.new("Nemo", "human")
	var fallen := Player.new("Bot", "bot")
	fallen.saved_fallen = true
	fallen.event_state.schedule(12)
	fallen.buildings[BuildingType.Value.ALGAE_FARM] = Building.new(BuildingType.Value.ALGAE_FARM, 3)
	var algae := fallen.resources[ResourceType.Value.ALGAE].amount
	var game := Game.new(human.id, {fallen.id: fallen, human.id: human}, 12)
	TurnResolver.new().resolve(game, DartRandom.new(3))
	assert_eq(fallen.resources[ResourceType.Value.ALGAE].amount, algae)
	assert_null(fallen.event_state.last_drawn)
	assert_eq(game.turn, 13)


func test_the_attacks_given_come_first_then_the_guardians() -> void:
	var war := LeviathanScene.of()
	var first := FactionAttackReport.new("a", "A", null, null)
	var second := FactionAttackReport.new("b", "B", null, null)
	var given: Array[FactionAttackReport] = [first, second]
	var result := TurnResolver.new().resolve(war.game, DartRandom.new(5), given)
	assert_eq(result.attacks, [first, second])
	assert_null(result.leviathan)
	while war.game.turn < LeviathanScene.strike_turn(war):
		TurnResolver.new().resolve(war.game, DartRandom.new(5))
	result = TurnResolver.new().resolve(war.game, DartRandom.new(5), given)
	assert_not_null(result.leviathan)
	assert_eq(result.attacks, [first, second, result.leviathan])
	assert_eq(given.size(), 2)

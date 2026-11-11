extends TestCase
## Not in the Dart files: the players a turn passes over, the human's result
## whoever plays first, the attacks it reports and the dice of the guardians,
## which the Dart tests reach through EndTurnAction.


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


func test_the_result_is_the_human_s_whoever_plays_first() -> void:
	var bot := Player.new("Bot", "bot")
	bot.recruited_unit_types.append(UnitType.Value.SCOUT)
	bot.raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.EASY, 5), 12)
	bot.event_state.set_pending(RandomEventType.Value.SURVIVORS, 12)
	var human := Player.new("Nemo", "human")
	human.event_state.schedule(30)
	var game := Game.new(human.id, {bot.id: bot, human.id: human}, 12)
	var result := TurnResolver.new().resolve(game, DartRandom.new(3))
	assert_false(result.had_recruited_units)
	assert_null(result.raid)
	assert_null(result.defaulted_event)
	assert_not_null(EventSamples.event_entries_of(bot)[0])


func test_the_guardians_fight_with_the_dice_of_the_turn() -> void:
	var reports: Array[String] = []
	for _i: int in 2:
		var war := LeviathanScene.of()
		var strike := LeviathanScene.strike_turn(war)
		var result: TurnResult = null
		while war.game.turn <= strike:
			if war.game.turn == strike:
				war.put(war.human(), war.below(), {UnitType.Value.HARPOONIST: 8, UnitType.Value.GUARDIAN: 4})
			result = TurnResolver.new().resolve(war.game, DartRandom.new(5))
		reports.append(LeviathanDigests.report(result.leviathan))
	assert_ne(reports[0], "-")
	assert_eq(reports[0], reports[1])

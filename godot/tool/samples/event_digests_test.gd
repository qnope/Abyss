extends TestCase
## The texts and the choices of the digest test of the random events.

const CARAVAN := RandomEventType.Value.CARAVAN


func _waiting(type: RandomEventType.Value) -> Player:
	var player := EventSamples.event_player()
	player.event_state.set_pending(type, 6)
	return player


func test_chooses_on_three_turns_of_four_as_the_action_does() -> void:
	var player := _waiting(RandomEventType.Value.COLD_CURRENT)
	var game := EventSamples.event_game(player, 6)
	assert_eq(EventDigests.choose(game, player, 6, 2), "")
	assert_eq(EventDigests.choose(game, player, 5, 1), "")
	assert_eq(EventDigests.choose(game, player, 6, 1), "6 NcoldCurrent")
	assert_false(player.event_state.has_pending())
	assert_eq(HistoryDigests.entry(player.history_entries[0]), "event 6 coldCurrent false false")
	assert_eq(EventDigests.choose(game, player, 6, 1), "")
	var poor := _waiting(CARAVAN)
	poor.event_state.trade_from = ResourceType.Value.CORAL
	poor.resources[ResourceType.Value.CORAL].amount = 10
	assert_eq(EventDigests.choose(game, poor, 6, 0), "6 ?caravan notEnoughStockToTrade")
	var faced := _waiting(RandomEventType.Value.PREDATORS)
	assert_eq(EventDigests.choose(game, faced, 6, 1), "6 Ypredators")


func test_writes_what_a_draw_left_a_report_and_a_state() -> void:
	var player := EventSamples.event_player()
	var s := player.event_state
	s.last_drawn = RandomEventType.Value.STORM
	assert_eq(EventDigests.drawn(player), "")
	s.last_drawn = RandomEventType.Value.SURVIVORS
	s.survivors = 3
	assert_eq(EventDigests.drawn(player), " 3")
	s.last_drawn = CARAVAN
	s.trade_from = ResourceType.Value.CORAL
	assert_eq(EventDigests.drawn(player), " coral>null")
	s.last_drawn = RandomEventType.Value.WRECK
	s.wreck_position = GridPosition.new(4, 5)
	assert_eq(EventDigests.drawn(player), "@4,5")
	s.last_drawn = RandomEventType.Value.PREDATORS
	s.predator_wave = MonsterLair.new(MonsterDifficulty.Value.EASY, 3)
	assert_eq(EventDigests.drawn(player), " easy/null/3/null/0")
	var fight := FightResult.new(CombatSide.Value.PLAYER, 4, [], [], [], 5, 0)
	var report := RaidReport.new(12, true, s.predator_wave, fight, 0, {}, {}, {}, {}, {ResourceType.Value.ORE: 3}, {})
	assert_eq(EventDigests.report(report), "V easy/null/3/null/0 0 0 3 0 4")
	assert_eq(
		EventDigests.state(EventSamples.event_player()),
		"null null 0 null null null false null,null null | 0 0 0 0 | 100 300 150 100 5 | 0 0 0 0 0 0",
	)
	assert_eq([EventDigests.name_of(null), EventDigests.name_of(CARAVAN)], ["null", "caravan"])

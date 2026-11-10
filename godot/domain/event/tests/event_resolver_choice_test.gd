extends TestCase
## test/domain/event/event_resolver_choice_test.dart: the events left
## without a choice, and those drawn without one.

const CARAVAN := RandomEventType.Value.CARAVAN
const STORM := RandomEventType.Value.STORM


func _waiting(pending_turn: int) -> Player:
	var player := EventSamples.event_player()
	player.event_state.schedule(30)
	player.event_state.set_pending(CARAVAN, pending_turn)
	return player


func _resolve(player: Player, turn: int, random: DartRandom) -> EventTurnOutcome:
	return EventResolver.resolve(EventSamples.event_game(player, turn), player, turn, random)


func test_the_prudent_option_applies_when_the_player_did_not_choose() -> void:
	var player := _waiting(12)
	var outcome := _resolve(player, 12, DartRandom.new(1))
	assert_eq(outcome.defaulted, CARAVAN)
	assert_false(player.event_state.has_pending())
	var entries := EventSamples.event_entries_of(player)
	assert_eq(entries.size(), 1)
	assert_eq([entries[0].turn, entries[0].type, entries[0].accepted, entries[0].defaulted], [12, CARAVAN, false, true])


func test_an_event_waiting_for_a_later_turn_is_left_to_the_player() -> void:
	var player := _waiting(13)
	assert_null(_resolve(player, 12, DartRandom.new(1)).defaulted)
	assert_eq(player.event_state.pending, CARAVAN)
	assert_true(EventSamples.event_entries_of(player).is_empty())


func test_an_event_without_a_choice_applies_at_the_draw_never_pending() -> void:
	var storms := 0
	for seed_: int in 100:
		var player := EventSamples.event_player()
		player.event_state.schedule(12)
		if _resolve(player, 12, DartRandom.new(seed_)).drawn != STORM:
			continue
		storms += 1
		assert_false(player.event_state.has_pending())
		assert_eq([player.event_state.last_drawn, player.event_state.events_seen], [STORM, 1])
		var entries := EventSamples.event_entries_of(player)
		assert_eq(entries.size(), 1)
		assert_eq([entries[0].type, entries[0].defaulted], [STORM, false])
	assert_true(storms > 0)


func test_no_predators_when_a_raid_hits_at_the_end_of_the_next_turn() -> void:
	for seed_: int in 200:
		var player := EventSamples.event_player()
		player.event_state.schedule(20)
		player.raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.EASY, 3), 21)
		assert_ne(_resolve(player, 20, DartRandom.new(seed_)).drawn, RandomEventType.Value.PREDATORS)


func test_the_same_seed_draws_the_same_events() -> void:
	var first := _play()
	assert_eq(_play(), first)
	var events := first.slice(0, 160)
	assert_true(events.any(func(event: Variant) -> bool: return event != null))


func _play() -> Array:
	var player := EventSamples.event_player()
	var game := EventSamples.event_game(player)
	var random := DartRandom.new(42)
	var played := []
	for turn: int in range(1, 81):
		var o := EventResolver.resolve(game, player, turn, random)
		played.append_array([o.drawn, o.defaulted])
	played.append_array([player.event_state.next_draw_turn, player.event_state.events_seen])
	return played

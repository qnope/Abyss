extends CodecTestCase
## ThreatCodec and EventCodec: what comes at a player, written and read
## back, empty and full.

const Unit := UnitType.Value


static func _lair() -> MonsterLair:
	return MonsterLair.new(MonsterDifficulty.Value.HARD, 5, MonsterFamily.Value.SWARM)


func test_an_attack_and_a_raid_state_empty_or_full() -> void:
	var units: Dictionary[UnitType.Value, int] = {Unit.SABOTEUR: 2, Unit.SCOUT: 1}
	var attack := AnnouncedAttack.new("faction-pearlOrder", units, 12, 123456789)
	assert_round_trip(ThreatSnapshots.attack(), ThreatCodec.attack, ThreatCodec.read_attack, attack)
	assert_round_trip(ThreatSnapshots.raid(), ThreatCodec.raid, ThreatCodec.read_raid, RaidState.new())
	var attacks: Array[AnnouncedAttack] = [attack]
	var full := RaidState.new(
		30, 120, _lair(), 9, 1, 2, 3, attacks, 40, {"faction-a": 7, "h": 2}, {"faction-b": 8},
	)
	var read: RaidState = assert_round_trip(ThreatSnapshots.raid(), ThreatCodec.raid, ThreatCodec.read_raid, full)
	assert_eq(read.post_attack_turns.keys(), ["faction-a", "h"])


func test_a_volcano_state_and_the_leviathan_empty_or_full() -> void:
	assert_round_trip(ThreatSnapshots.volcano(), ThreatCodec.volcano, ThreatCodec.read_volcano, VolcanoState.new())
	assert_round_trip(ThreatSnapshots.volcano(), ThreatCodec.volcano, ThreatCodec.read_volcano,
		VolcanoState.new(_lair(), 14, 2, 1))
	assert_round_trip(ThreatSnapshots.leviathan(), ThreatCodec.leviathan, ThreatCodec.read_leviathan,
		LeviathanReturn.new())
	assert_round_trip(ThreatSnapshots.leviathan(), ThreatCodec.leviathan, ThreatCodec.read_leviathan,
		LeviathanReturn.new("Faille Nord", 1, GridPosition.new(3, 4), 20, true, 25))


func test_what_scouts_know_of_another_base() -> void:
	var army: Dictionary[UnitType.Value, int] = {Unit.GUARDIAN: 6}
	var stocks: Dictionary[ResourceType.Value, int] = {ResourceType.Value.ORE: 90, ResourceType.Value.ALGAE: 10}
	assert_round_trip(ThreatSnapshots.intel(), ThreatCodec.intel, ThreatCodec.read_intel,
		BaseIntel.new(8, 3, 2, army, stocks))


func test_the_random_events_empty_or_full() -> void:
	assert_round_trip(ThreatSnapshots.event(), EventCodec.event_state, EventCodec.read_event_state, EventState.new())
	var full := EventState.new(
		10, RandomEventType.Value.CARAVAN, 9, RandomEventType.Value.WRECK, RandomEventType.Value.STORM, 12, true, 4,
		3, ResourceType.Value.CORAL, ResourceType.Value.PEARL, _lair(), 11, GridPosition.new(1, 1), 13,
	)
	assert_round_trip(ThreatSnapshots.event(), EventCodec.event_state, EventCodec.read_event_state, full)


func test_a_turn_that_is_no_whole_number_is_a_problem() -> void:
	var raid := JSON.stringify(ThreatCodec.raid(RaidState.new()), "", false)
	assert_eq(problem_of(ThreatCodec.read_raid, raid.replace("\"arrivalTurn\":null", "\"arrivalTurn\":2.5")),
		"arrivalTurn is not a whole number")
	assert_eq(problem_of(ThreatCodec.read_raid, raid.replace("\"postAttackTurns\":{}", "\"postAttackTurns\":{\"a\":true}")),
		"postAttackTurns is not a whole number")

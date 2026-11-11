extends TestCase
## test/domain/faction/faction_scouting_test.dart: how deep a faction scouts.

const Personality := FactionPersonality.Value


func test_an_expedition_keeps_6_scouts_deep_the_nomads_8() -> void:
	for p: Personality in Personality.values():
		assert_eq(
			FactionScouting.deep_scouts_of(p),
			8 if p == Personality.CURRENT_NOMADS else 6,
			DartEnum.name_of(Personality, p)
		)
	assert_eq(FactionScouting.DEEP_EXPLORERS, 3)


## A war slot of the first faction with no scout left and rich stocks.
static func _rich_and_blind() -> War:
	var war := War.new()
	AssaultSamples.station(war.attacker(), AssaultSamples.HORDE)
	AssaultSamples.set_level(war.attacker(), BuildingType.Value.BARRACKS, 1)
	for r: GameResource in war.attacker().resources.values():
		r.amount = 5000
	return war


func test_the_spy_slot_recruits_the_whole_need_of_scouts_at_once() -> void:
	var war := _rich_and_blind()
	var p := war.personality()
	var wanted := ScoutMoves.scouts_wanted(
		war.turn(), FactionTraits.of(p).explorers, FactionScouting.deep_scouts_of(p), true
	)

	war.play()

	assert_eq(
		AssaultSamples.standing(war.attacker(), UnitType.Value.SCOUT), wanted + 1,
		"the need, plus the spy of the slot"
	)


func test_a_slot_does_not_cost_the_exploration_of_the_turn() -> void:
	var war := _rich_and_blind()
	var p := war.personality()

	FactionBrain.new(p).play_turn(war.turn())

	var level1 := 0
	for o: ExplorationOrder in war.attacker().pending_explorations:
		if o.level == 1:
			level1 += 1
	assert_eq(level1, FactionTraits.of(p).explorers)


func test_a_poor_faction_still_keeps_one_scout_for_the_spy() -> void:
	var war := War.new()
	AssaultSamples.station(war.attacker(), AssaultSamples.HORDE)
	AssaultSamples.set_level(war.attacker(), BuildingType.Value.BARRACKS, 1)
	for r: GameResource in war.attacker().resources.values():
		r.amount = 0
	war.attacker().resources[ResourceType.Value.ALGAE].amount = 10
	war.attacker().resources[ResourceType.Value.CORAL].amount = 5

	war.play()

	assert_eq(AssaultSamples.standing(war.attacker(), UnitType.Value.SCOUT), 1)

extends TestCase
## test/domain/faction/faction_war_test.dart: when and whom a faction
## attacks.

const Personality := FactionPersonality.Value
const HARPOONIST := UnitType.Value.HARPOONIST
const HORDE := AssaultSamples.HORDE


func test_it_attacks_the_human_it_has_seen_and_can_beat_this_very_turn() -> void:
	var war := War.new()
	war.see(war.human())

	war.play()

	assert_eq(war.human().raid_state.attacks.size(), 1)
	var attack := war.human().raid_state.attacks[0]
	assert_eq(attack.attacker_id, war.attacker().id)
	assert_eq(attack.units.keys(), HORDE.keys())
	assert_eq(attack.arrival_turn, war.game.turn)


func test_it_sends_the_fewest_units_that_still_win_not_its_whole_army() -> void:
	var war := War.new()
	war.see(war.human())

	war.play()

	var sent: int = war.human().raid_state.attacks[0].units[HARPOONIST]
	assert_true(sent > 0)
	assert_true(sent < HORDE[HARPOONIST])


func test_it_only_strikes_on_its_slot_every_few_turns() -> void:
	var war := War.new()
	war.see(war.human())
	war.game.turn += 1

	war.play()

	assert_eq(war.human().raid_state.attacks.size(), 0)


func test_every_personality_has_a_slot_every_cadence_turns_no_more() -> void:
	for p: Personality in Personality.values():
		var slots: Array[int] = []
		for t: int in range(1, 61):
			if FactionWar.is_due(t, p):
				slots.append(t)
		var cadence := FactionTraits.of(p).cadence
		var least := DartMath.trunc_div(60, cadence)
		assert_true(slots.size() >= least and slots.size() <= least + 1)
		for i: int in range(1, slots.size()):
			assert_eq(slots[i] - slots[i - 1], cadence)


func test_it_leaves_alone_a_base_its_fog_never_showed() -> void:
	var war := War.new()

	war.play()

	assert_eq(war.human().raid_state.attacks.size(), 0)


func test_it_does_not_attack_a_defence_stronger_than_its_army() -> void:
	var war := War.new()
	war.see(war.human())
	AssaultSamples.station(war.human(), AssaultSamples.WALL)

	war.play()

	assert_eq(war.human().raid_state.attacks.size(), 0)
	assert_eq(AssaultSamples.standing(war.attacker(), HARPOONIST), 40)


func test_it_picks_the_weakest_base_it_knows_a_faction_is_hit_at_once() -> void:
	var war := War.new()
	war.see(war.human())
	war.see(war.rival())
	AssaultSamples.station(war.human(), AssaultSamples.WALL)

	war.play()

	assert_eq(war.human().raid_state.attacks.size(), 0)
	assert_eq(War.assaults(war.rival()).size(), 1)
	assert_eq(War.assaults(war.attacker()).size(), 1)


func test_it_announces_nothing_while_the_tutorial_of_the_human_runs() -> void:
	var war := War.new()
	war.see(war.human())
	ObjectiveMigration.state_of(war.game, war.human()).tutorial_enabled = true

	war.play()

	assert_eq(war.human().raid_state.attacks.size(), 0)


func test_it_has_one_attack_pending_at_a_time() -> void:
	var war := War.new()
	war.see(war.human())

	war.play()
	war.play()

	assert_eq(war.human().raid_state.attacks.size(), 1)


func test_scouts_and_admirals_stay_home() -> void:
	var war := War.new()
	war.see(war.human())
	var army: Dictionary[UnitType.Value, int] = {}
	army.merge(HORDE)
	army[UnitType.Value.SCOUT] = 3
	AssaultSamples.station(war.attacker(), army)

	war.play()

	assert_eq(war.human().raid_state.attacks[0].units.keys(), HORDE.keys())

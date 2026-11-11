extends TestCase
## test/domain/faction/faction_grudge_test.dart: on a grudge slot a faction
## goes for the human it can beat.

const Personality := FactionPersonality.Value


## A war where the human is stronger than the rival, but still beatable.
static func _war(grudge: bool) -> War:
	var war := War.new()
	var p := war.personality()
	while not FactionWar.is_due(war.game.turn, p) or FactionWar.is_grudge_slot(war.game.turn, p) != grudge:
		war.game.turn += 1
	war.see(war.human())
	war.see(war.rival())
	AssaultSamples.station(war.human(), {UnitType.Value.HARPOONIST: 6})
	return war


func test_a_grudge_slot_comes_every_few_slots_never_off_a_slot() -> void:
	for p: Personality in Personality.values():
		var every := FactionTraits.of(p).grudge_every
		var slots := 0
		var grudges := 0
		for t: int in range(1, 121):
			if FactionWar.is_due(t, p):
				slots += 1
				if FactionWar.is_grudge_slot(t, p):
					grudges += 1
			else:
				assert_false(FactionWar.is_grudge_slot(t, p))
		assert_true(grudges > 0, DartEnum.name_of(Personality, p))
		var ratio := DartMath.trunc_div(slots, grudges)
		assert_true(ratio >= every - 1 and ratio <= every + 1)


func test_the_pillagers_and_the_horde_hold_the_grudge_sooner_than_the_rest() -> void:
	assert_eq(FactionTraits.of(Personality.PEARL_ORDER).grudge_every, 3)
	for p: Personality in [Personality.WRECK_PILLAGERS, Personality.MURENA_HORDE] as Array[Personality]:
		assert_eq(FactionTraits.of(p).grudge_every, 2)


func test_on_a_grudge_slot_it_hits_the_human_it_can_beat_not_the_weakest() -> void:
	var war := _war(true)

	war.play()

	assert_eq(war.human().raid_state.attacks.size(), 1)
	assert_eq(War.assaults(war.rival()).size(), 0)


func test_on_another_slot_it_still_hits_the_weakest_base() -> void:
	var war := _war(false)

	war.play()

	assert_eq(war.human().raid_state.attacks.size(), 0)
	assert_eq(War.assaults(war.rival()).size(), 1)


func test_a_grudge_never_sends_an_army_that_loses_it_falls_back() -> void:
	var war := _war(true)
	AssaultSamples.station(war.human(), AssaultSamples.WALL)

	war.play()

	assert_eq(war.human().raid_state.attacks.size(), 0)
	assert_eq(War.assaults(war.rival()).size(), 1)


func test_a_grudge_needs_a_base_the_fog_showed() -> void:
	var fresh := War.new()
	while not FactionWar.is_grudge_slot(fresh.game.turn, fresh.personality()):
		fresh.game.turn += 1
	fresh.see(fresh.rival())
	AssaultSamples.station(fresh.human(), {UnitType.Value.HARPOONIST: 6})

	fresh.play()

	assert_eq(fresh.human().raid_state.attacks.size(), 0)

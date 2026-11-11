extends TestCase
## test/domain/faction/faction_spy_test.dart: a faction spies on a base
## before it attacks it.

const SCOUT := UnitType.Value.SCOUT


func test_it_spies_on_a_base_before_it_attacks_it() -> void:
	var war := War.new()
	war.see(war.human())

	war.play()

	assert_not_null(war.attacker().intel().get(war.human().id))
	assert_eq(AssaultSamples.standing(war.attacker(), SCOUT), 1)
	assert_eq(war.human().raid_state.attacks.size(), 1)


func test_without_a_scout_it_attacks_nothing_blind() -> void:
	var war := War.new()
	war.see(war.human())
	AssaultSamples.station(war.attacker(), AssaultSamples.HORDE)

	war.play()

	assert_eq(war.attacker().intel().size(), 0)
	assert_eq(war.human().raid_state.attacks.size(), 0)


func test_it_reads_the_report_not_the_base_an_army_that_left_can_surprise() -> void:
	var war := War.new()
	war.see(war.human())
	SpyBaseAction.new(war.human().id).execute(war.game, war.attacker())
	AssaultSamples.station(war.human(), AssaultSamples.WALL)

	war.play()

	assert_eq(war.human().raid_state.attacks.size(), 1, "the fresh report said the base was empty")
	assert_eq(AssaultSamples.standing(war.attacker(), SCOUT), 1, "a fresh report is not paid for again")


func test_a_stale_report_is_renewed_before_the_attack() -> void:
	var war := War.new()
	war.see(war.human())
	SpyBaseAction.new(war.human().id).execute(war.game, war.attacker())
	war.game.turn += 12
	while not war.is_due():
		war.game.turn += 1
	AssaultSamples.station(war.human(), AssaultSamples.WALL)

	war.play()

	assert_eq(war.attacker().intel()[war.human().id].turn, war.game.turn)
	assert_eq(war.human().raid_state.attacks.size(), 0, "the renewed report shows the wall")


func test_it_spies_the_base_it_knows_before_choosing_the_weakest() -> void:
	var war := War.new()
	war.see(war.human())
	war.see(war.rival())
	AssaultSamples.station(war.human(), AssaultSamples.WALL)

	war.play()

	assert_has(war.attacker().intel(), war.human().id)
	assert_has(war.attacker().intel(), war.rival().id)
	assert_eq(AssaultSamples.standing(war.attacker(), SCOUT), 0)

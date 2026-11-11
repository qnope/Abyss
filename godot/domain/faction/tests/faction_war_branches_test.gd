extends TestCase
## Not in the Dart files: branches of the war of the factions the Dart
## tests reach only through whole games: the Faithful forget the cold
## kernel on a grudge slot, the cap of the sieges a holder loses in a turn
## spares a cold kernel, and a fallen faction is no target, even spied.

const Personality := FactionPersonality.Value


static func _faithful_war(grudge: bool) -> KernelWar:
	var p: Array[Personality] = [Personality.KRAKEN_FAITHFUL, Personality.MURENA_HORDE]
	var war := KernelWar.new(3, 7, false, p)
	war.arm()
	war.garrison(KernelWar.SMALL_GARRISON)
	var faithful := Personality.KRAKEN_FAITHFUL
	while not FactionWar.is_due(war.game.turn, faithful) or FactionWar.is_grudge_slot(war.game.turn, faithful) != grudge:
		war.game.turn += 1
	return war


static func _play(war: KernelWar) -> void:
	FactionWar.play(
		FactionTurn.new(war.game, war.attacker(), ActionExecutor.new(), DartRandom.new(2, false)),
		Personality.KRAKEN_FAITHFUL,
	)


func test_on_a_grudge_slot_the_faithful_leave_a_cold_kernel_alone() -> void:
	var war := _faithful_war(true)

	_play(war)

	assert_eq(war.kernel_of(war.owner()), 3)
	assert_eq(War.assaults(war.owner()).size(), 0)


func test_on_another_slot_the_faithful_besiege_it() -> void:
	var war := _faithful_war(false)

	_play(war)

	assert_eq(war.kernel_of(war.owner()), 2)


func test_the_cap_of_the_sieges_lost_this_turn_leaves_a_cold_kernel_open() -> void:
	var war := KernelWar.new(3)
	war.arm()
	war.garrison(KernelWar.SMALL_GARRISON)
	war.game.saved_difficulty = Difficulty.Value.EASY
	war.put(war.human(), 3, KernelWar.HORDE)
	ActionExecutor.new().execute(war.strike(KernelWar.HORDE), war.game, war.human())
	assert_true(KernelSiege.is_capped(war.game, war.owner()))
	war.attacker().add_revealed_cell(3, war.at)
	var turn := FactionTurn.new(war.game, war.attacker(), ActionExecutor.new(), DartRandom.new(2, false))

	assert_true(FactionKernelWar.besiege_cold(turn, ArmyPlanner.new()))
	assert_eq(war.kernel_of(war.owner()), 1)


func test_a_fallen_faction_is_no_target() -> void:
	var war := War.new()
	war.see(war.human())
	war.see(war.rival())
	var ours := CombatantBuilder.player_combatants_from(AssaultSamples.HORDE)
	assert_eq(FactionBaseTargets.weakest_first(war.turn(), ours).size(), 2, "both spied")
	war.rival().saved_fallen = true

	var targets := FactionBaseTargets.weakest_first(war.turn(), ours)

	assert_eq(targets.size(), 1)
	assert_eq(targets[0].player.id, war.human().id)

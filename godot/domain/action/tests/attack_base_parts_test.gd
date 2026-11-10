extends TestCase
## Not in the Dart files: the parts of an attack on a base that
## AttackBaseAction puts together, and the attacks on a post and on a
## kernel too: the defences, their settling, the result and the two history
## entries.

const GUARDIAN := UnitType.Value.GUARDIAN
const HARPOONIST := UnitType.Value.HARPOONIST
const MONSTER := CombatSide.Value.MONSTER


func _sides(defence: BaseDefence) -> Array:
	return defence.side.map(func(c: Combatant) -> String: return "%s/%s" % [c.type_key, c.side])


func test_the_defences_of_a_base_a_post_a_report_and_a_kernel() -> void:
	var game := AssaultSamples.assault_game()
	var rival := AssaultSamples.rival_of(game)
	AssaultSamples.station(rival, {GUARDIAN: 2, HARPOONIST: 1})
	AssaultSamples.set_level(rival, BuildingType.Value.CORAL_CITADEL, 3)
	var base := BaseDefence.of(rival)
	assert_eq([base.engaged, base.level, base.side.size()], [{GUARDIAN: 2, HARPOONIST: 1}, 1, 4])
	assert_true(base.side.all(func(c: Combatant) -> bool: return c.side == MONSTER))
	assert_eq(base.side[3].max_hp, CoralCitadelRampart.combatant_of(rival.buildings).max_hp)
	RaidSamples.set_units(rival, HARPOONIST, 5, 2)
	var post := BaseDefence.post(rival, 2)
	assert_eq([post.engaged, post.level, post.side.size()], [{HARPOONIST: 5}, 2, 5])
	var intel := BaseIntel.new(12, 5, 0, {GUARDIAN: 1}, {})
	assert_eq(_sides(BaseDefence.from_intel(intel)), ["guardian/%d" % MONSTER])
	intel.rampart_level = 2
	assert_eq(BaseDefence.from_intel(intel).side.size(), 2)
	var holder := RaidSamples.volcano_player(2, {GUARDIAN: 3})
	var kernel := BaseDefence.kernel(holder)
	assert_eq([kernel.engaged, kernel.level, kernel.side.size()], [{GUARDIAN: 3}, KernelGarrison.STOCK_KEY, 4])
	assert_eq(BaseDefence.kernel(RaidSamples.volcano_player(0, {GUARDIAN: 1})).side.size(), 1)


func test_a_fight_settles_into_a_result_and_two_entries() -> void:
	var game := AssaultSamples.assault_game()
	var attacker := game.human_player()
	var rival := AssaultSamples.rival_of(game)
	AssaultSamples.station(rival, {GUARDIAN: 3, HARPOONIST: 4})
	var defence := BaseDefence.of(rival)
	var army := CombatantBuilder.player_combatants_from(AssaultSamples.HORDE)
	var fight := FightEngine.new(DartRandom.new(1)).resolve(army, defence.side)
	var outcome := defence.settle(rival, DartRandom.new(2))
	assert_eq(outcome.engaged, {GUARDIAN: 3, HARPOONIST: 4})
	assert_eq(outcome.initial.size(), 7)
	assert_true(outcome.initial.all(func(c: Combatant) -> bool: return c.is_alive()))
	var back := 0
	for count: int in outcome.survivors_intact.values() + outcome.wounded.values():
		back += count
	assert_eq(RaidSamples.units_on_base(rival), back)
	var damage := BaseRaze.apply(attacker, rival)
	var result := AttackBaseResult.success(true, fight, AssaultSamples.HORDE, {HARPOONIST: 40}, {}, {}, outcome, damage)
	assert_true(result.is_success)
	var mine := AttackBaseEntries.for_attacker(12, rival.name, result)
	assert_eq([mine.turn, mine.victory, mine.defending, mine.opponent_name, mine.units], [12, true, false, "rival", AssaultSamples.HORDE])
	assert_eq([mine.headquarters_before, mine.headquarters_after, mine.post_name], [5, 4, null])
	var theirs := AttackBaseEntries.for_defender(12, attacker.name, result, "Faille", {GUARDIAN: 1}, false)
	assert_eq([theirs.defending, theirs.units, theirs.dead, theirs.post_name], [true, outcome.engaged, outcome.dead, "Faille"])
	assert_eq([theirs.lost_with_post, theirs.passage_destroyed, theirs.fight_result == fight], [{GUARDIAN: 1}, false, true])
	var refused := AttackBaseResult.failure(ActionFailure.Value.PLAYER_FALLEN)
	assert_eq([refused.is_success, refused.victory, refused.sent, refused.defence], [false, false, {}, null])


func test_defenders_who_hold_go_back_to_the_base() -> void:
	var rival := AssaultSamples.rival_of(AssaultSamples.assault_game())
	AssaultSamples.station(rival, {GUARDIAN: 3})
	var defence := BaseDefence.of(rival)
	var army := CombatantBuilder.player_combatants_from({UnitType.Value.SCOUT: 1})
	FightEngine.new(DartRandom.new(1)).resolve(army, defence.side)
	var outcome := defence.settle(rival, DartRandom.new(2))
	assert_eq([outcome.survivors_intact, outcome.dead], [{GUARDIAN: 3}, {}])
	assert_eq(AssaultSamples.standing(rival, GUARDIAN), 3)

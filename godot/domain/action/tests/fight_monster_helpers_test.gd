extends TestCase
## Not in the Dart files: lib/domain/action/fight_monster_helpers.dart has no
## test of its own, its Dart tests go through the actions (the action
## module). What it answers, read from the Dart rules by a scratch script;
## computePctLost is held by fight_monster_helpers_vectors_test.gd.

const SCOUT := UnitType.Value.SCOUT
const HARPOONIST := UnitType.Value.HARPOONIST
const GUARDIAN := UnitType.Value.GUARDIAN


func _fight(seed_: int, random: DartRandom) -> FightResult:
	var army: Dictionary[UnitType.Value, int] = {HARPOONIST: 8, SCOUT: 3, GUARDIAN: 2}
	var side := CombatantBuilder.player_combatants_from(army)
	side.append(CoralCitadelRampart.combatant_for(2))
	var lair := MonsterLair.new(MonsterDifficulty.Value.MEDIUM, 9)
	assert_eq(random.initial_seed, seed_)
	return FightEngine.new(random).resolve(side, CombatantBuilder.monster_combatants_from(lair))


func test_resolve_casualties_splits_the_fallen_and_restores_the_rest_as_dart() -> void:
	# Seed: [pctLost, intact, wounded, dead, stock after, next nextInt(1000)],
	# the shares by their bits: GDScript reads 0.39285714285714285 one bit off.
	var dart := {
		1: [_bits("3fd9249249249249"), {HARPOONIST: 8, SCOUT: 3}, {}, {GUARDIAN: 2}, {SCOUT: 3, HARPOONIST: 8}, 2],
		5: [_bits("3fd9d41d41d41d42"), {HARPOONIST: 8, SCOUT: 3}, {GUARDIAN: 2}, {}, {SCOUT: 3, HARPOONIST: 8, GUARDIAN: 2}, 594],
		9: [_bits("3fd457c57c57c57c"), {HARPOONIST: 8, SCOUT: 3}, {GUARDIAN: 2}, {}, {SCOUT: 3, HARPOONIST: 8, GUARDIAN: 2}, 490],
	}
	for seed_: int in dart:
		var player := GameSamples.player("p")
		var random := DartRandom.new(seed_)
		var result := _fight(seed_, random)
		var lost := FightMonsterHelpers.compute_pct_lost(
			result.initial_player_combatants, result.final_player_combatants
		)
		var b := FightMonsterHelpers.resolve_casualties(player, 1, result, random)
		var got := [lost, b.survivors_intact, b.wounded, b.dead, player.unit_counts_on_level(1), random.next_int(1000)]
		assert_eq(got, dart[seed_], "seed %d" % seed_)


func _bits(hex: String) -> float:
	return VectorValues.float_of(hex)


func test_combatants_by_type_counts_the_units_and_skips_the_rest() -> void:
	var side := CombatantBuilder.player_combatants_from({GUARDIAN: 2, SCOUT: 1})
	side.insert(1, CoralCitadelRampart.combatant_for(1))
	side.append(Combatant.new(CombatSide.Value.PLAYER, "harpoonist", 15, 5, 2))
	var counts := FightMonsterHelpers.combatants_by_type(side)
	assert_eq(counts, {GUARDIAN: 2, SCOUT: 1, HARPOONIST: 1})
	assert_eq(counts.keys(), [GUARDIAN, SCOUT, HARPOONIST])


func test_restore_to_stock_adds_one_unit_per_combatant() -> void:
	var player := GameSamples.player("p")
	player.units_on_level(1)[SCOUT].count = 2
	var side := CombatantBuilder.player_combatants_from({SCOUT: 3, HARPOONIST: 1})
	side.append(CoralCitadelRampart.combatant_for(1))
	FightMonsterHelpers.restore_to_stock(player, side, 1)
	assert_eq(player.unit_counts_on_level(1), {SCOUT: 5, HARPOONIST: 1})


func test_restore_to_stock_on_a_level_without_units_fails_as_dart_throws() -> void:
	var player := GameSamples.player("p")
	expect_error("no harpoonist")
	FightMonsterHelpers.restore_to_stock(player, CombatantBuilder.player_combatants_from({HARPOONIST: 1}), 2)
	assert_false(player.units_per_level.has(2))


func test_apply_loot_credits_the_stocks_up_to_their_storage() -> void:
	var player := GameSamples.player("p")
	var algae: GameResource = player.resources[ResourceType.Value.ALGAE]
	algae.amount = algae.max_storage - 10
	var added := FightMonsterHelpers.apply_loot(
		player, {ResourceType.Value.ALGAE: 30, ResourceType.Value.PEARL: 2}
	)
	assert_eq(added, {ResourceType.Value.ALGAE: 10, ResourceType.Value.PEARL: 2})
	assert_eq(algae.amount, algae.max_storage)


func test_unit_boost_of_reads_the_research_on_offence_and_on_the_base() -> void:
	var player := GameSamples.player("p")
	player.tech_branches[TechBranch.Value.MILITARY] = TechHelpers.researched_branch(
		TechBranch.Value.MILITARY, 4, [TechOption.Value.B, TechOption.Value.B]
	)
	var effects := TechEffects.of(player)
	for flags: Array in [[false, false], [true, false], [false, true]]:
		var attacking: bool = flags[0]
		var defending_base: bool = flags[1]
		var boost := FightMonsterHelpers.unit_boost_of(player, attacking, defending_base)
		var expected := effects.unit_boost(attacking, defending_base)
		assert_eq(
			[boost.atk_percent, boost.def_percent, boost.hp_percent],
			[expected.atk_percent, expected.def_percent, expected.hp_percent],
		)
	var plain := FightMonsterHelpers.unit_boost_of(GameSamples.player("q"))
	assert_eq([plain.atk_percent, plain.def_percent, plain.hp_percent], [0, 0, 0])


func test_build_combat_entry_carries_the_fight_or_none_without_one() -> void:
	var fight := FightResult.new(CombatSide.Value.PLAYER, 3, [], [], [], 4, 0)
	var lair := MonsterLair.new(MonsterDifficulty.Value.EASY, 4)
	var loot: Dictionary[ResourceType.Value, int] = {ResourceType.Value.CORAL: 9}
	var sent: Dictionary[UnitType.Value, int] = {SCOUT: 3, HARPOONIST: 2}
	var intact: Dictionary[UnitType.Value, int] = {SCOUT: 3}
	var wounded: Dictionary[UnitType.Value, int] = {HARPOONIST: 1}
	var dead: Dictionary[UnitType.Value, int] = {HARPOONIST: 1}
	var won := FightMonsterResult.success(true, fight, loot, sent, intact, wounded, dead)
	var e := FightMonsterHelpers.build_combat_entry(7, 4, 5, lair, won)
	assert_eq([e.turn, e.category, e.victory, e.target_x, e.target_y], [7, HistoryEntryCategory.Value.COMBAT, true, 4, 5])
	assert_eq([e.lair, e.fight_result, e.loot, e.sent], [lair, fight, loot, sent])
	assert_eq([e.survivors_intact, e.wounded, e.dead], [intact, wounded, dead])
	assert_null(FightMonsterHelpers.build_combat_entry(7, 4, 5, null, won))
	var failed := FightMonsterResult.failure(ActionFailure.Value.LAIR_EMPTY)
	assert_null(FightMonsterHelpers.build_combat_entry(7, 4, 5, lair, failed))

extends TestCase
## test/domain/fight/combatant_builder_test.dart, the groups
## playerCombatantsFrom and monsterCombatantsFrom; the military bonus and
## unitTypeFromKey are in combatant_builder_bonus_test.gd.

const SCOUT := UnitType.Value.SCOUT
const HARPOONIST := UnitType.Value.HARPOONIST


func _stats_of(c: Combatant) -> Array:
	return [c.side, c.type_key, c.max_hp, c.atk, c.def, c.current_hp]


func test_player_combatants_from_expands_selected_units_into_per_unit_combatants_in_order() -> void:
	var combatants := CombatantBuilder.player_combatants_from({SCOUT: 3, HARPOONIST: 2})

	assert_eq(combatants.size(), 5)
	var scout := UnitStats.for_type(SCOUT)
	var harpoon := UnitStats.for_type(HARPOONIST)
	var player := CombatSide.Value.PLAYER
	for i: int in 3:
		assert_eq(_stats_of(combatants[i]),
			[player, "scout", scout.hp, scout.atk, scout.def, scout.hp])
	for i: int in range(3, 5):
		assert_eq(_stats_of(combatants[i]),
			[player, "harpoonist", harpoon.hp, harpoon.atk, harpoon.def, harpoon.hp])


func test_player_combatants_from_entries_with_count_0_are_skipped() -> void:
	var combatants := CombatantBuilder.player_combatants_from({
		SCOUT: 0, UnitType.Value.GUARDIAN: 2, UnitType.Value.SABOTEUR: 0,
	})

	assert_eq(combatants.size(), 2)
	assert_true(combatants.all(func(c: Combatant) -> bool: return c.type_key == "guardian"))


func test_player_combatants_from_empty_map_returns_empty_list() -> void:
	assert_true(CombatantBuilder.player_combatants_from({}).is_empty())


func test_monster_combatants_from_expands_easy_lair_into_level_1_combatants() -> void:
	var lair := MonsterLair.new(MonsterDifficulty.Value.EASY, 4)

	var combatants := CombatantBuilder.monster_combatants_from(lair)

	var level1 := MonsterUnitStats.for_level(1)
	assert_eq(combatants.size(), 4)
	for c: Combatant in combatants:
		assert_eq(_stats_of(c),
			[CombatSide.Value.MONSTER, "monsterL1", level1.hp, level1.atk, level1.def, level1.hp])


func test_monster_combatants_from_hard_lair_uses_monster_l3_key_and_level_3_stats() -> void:
	var lair := MonsterLair.new(MonsterDifficulty.Value.HARD, 2)

	var combatants := CombatantBuilder.monster_combatants_from(lair)

	var level3 := MonsterUnitStats.for_level(3)
	assert_eq(combatants.size(), 2)
	var first := combatants[0]
	assert_eq([first.type_key, first.max_hp, first.atk, first.def],
		["monsterL3", level3.hp, level3.atk, level3.def])


## Not in the Dart file: the side the units fight on, the defenders of a
## base fighting on the monsters' side, and a negative count skipped.
func test_builds_units_on_the_side_given() -> void:
	var defenders := CombatantBuilder.player_combatants_from(
		{SCOUT: 1, HARPOONIST: -2}, UnitBoost.none(), CombatSide.Value.MONSTER
	)
	assert_eq(defenders.size(), 1)
	assert_eq(defenders[0].side, CombatSide.Value.MONSTER)

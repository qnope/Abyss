extends TestCase
## test/domain/fight/combatant_builder_test.dart, the groups military bonus
## and CombatantBuilder.unitTypeFromKey.

const HARPOONIST := UnitType.Value.HARPOONIST
const GUARDIAN := UnitType.Value.GUARDIAN


func test_military_bonus_level_0_keeps_base_atk() -> void:
	var combatants := CombatantBuilder.player_combatants_from({HARPOONIST: 1})
	assert_eq(combatants[0].atk, UnitStats.for_type(HARPOONIST).atk)


func test_military_bonus_30_percent_atk_boost_is_applied_and_rounded() -> void:
	var combatants := CombatantBuilder.player_combatants_from({HARPOONIST: 1}, UnitBoost.new(30))
	assert_eq(combatants[0].atk, roundi(UnitStats.for_type(HARPOONIST).atk * 1.3))


func test_military_bonus_boost_applies_def_and_hp_independently() -> void:
	var combatants := CombatantBuilder.player_combatants_from({GUARDIAN: 1}, UnitBoost.new(0, 60, 20))
	# 6 * 1.6 = 9.6 -> 10 ; 25 * 1.2 = 30
	assert_eq(combatants[0].def, 10)
	assert_eq(combatants[0].max_hp, 30)
	assert_eq(combatants[0].atk, UnitStats.for_type(GUARDIAN).atk)


func test_military_bonus_bonus_does_not_affect_monster_combatants() -> void:
	var lair := MonsterLair.new(MonsterDifficulty.Value.EASY, 2)
	var combatants := CombatantBuilder.monster_combatants_from(lair)
	var level1 := MonsterUnitStats.for_level(1)
	for c: Combatant in combatants:
		assert_eq(c.atk, level1.atk)


func test_unit_type_from_key_returns_matching_unit_type_for_known_key() -> void:
	assert_eq(CombatantBuilder.unit_type_from_key("scout"), UnitType.Value.SCOUT)
	assert_eq(CombatantBuilder.unit_type_from_key("harpoonist"), HARPOONIST)


func test_unit_type_from_key_returns_null_for_monster_key() -> void:
	assert_null(CombatantBuilder.unit_type_from_key("monsterL1"))


func test_unit_type_from_key_returns_null_for_unknown_key() -> void:
	assert_null(CombatantBuilder.unit_type_from_key("unknown"))

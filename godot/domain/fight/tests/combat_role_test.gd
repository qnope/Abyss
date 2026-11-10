extends TestCase
## test/domain/fight/combat_role_test.dart: the special behaviour a unit
## brings to a fight.

const PLAYER := CombatSide.Value.PLAYER
const MONSTER := CombatSide.Value.MONSTER


func _c(key: String, side: CombatSide.Value) -> Combatant:
	return Combatant.new(side, key, 10, 1, 1)


func test_combat_role_for_unit_maps_each_special_unit_to_its_role() -> void:
	assert_eq(CombatRole.for_unit(UnitType.Value.GUARDIAN), CombatRole.Value.TAUNT)
	assert_eq(CombatRole.for_unit(UnitType.Value.DOME_BREAKER), CombatRole.Value.BOSS_BREAKER)
	assert_eq(CombatRole.for_unit(UnitType.Value.SABOTEUR), CombatRole.Value.ARMOUR_PIERCER)
	assert_eq(CombatRole.for_unit(UnitType.Value.SCOUT), CombatRole.Value.EVASIVE)
	assert_eq(CombatRole.for_unit(UnitType.Value.HARPOONIST), CombatRole.Value.NONE)
	assert_eq(CombatRole.for_unit(UnitType.Value.ABYSS_ADMIRAL), CombatRole.Value.NONE)


func test_combat_role_of_reads_the_role_of_a_player_combatant_from_its_type_key() -> void:
	assert_eq(CombatRole.of(_c("guardian", PLAYER)), CombatRole.Value.TAUNT)


func test_combat_role_of_monsters_never_have_a_role() -> void:
	assert_eq(CombatRole.of(_c("monsterL1", MONSTER)), CombatRole.Value.NONE)


func test_combat_role_of_the_defenders_of_a_base_keep_their_role_on_the_monsters_side() -> void:
	assert_eq(CombatRole.of(_c("guardian", MONSTER)), CombatRole.Value.TAUNT)
	assert_eq(CombatRole.of(_c(CombatRole.RAMPART_KEY, MONSTER)), CombatRole.Value.TAUNT)


## Not in the Dart file: a unit is read from its Dart name, as the type keys
## are written, and the names and the order the vectors write.
func test_reads_a_unit_from_its_dart_name_only() -> void:
	assert_eq(CombatRole.of(_c("domeBreaker", PLAYER)), CombatRole.Value.BOSS_BREAKER)
	assert_eq(CombatRole.of(_c("DOME_BREAKER", PLAYER)), CombatRole.Value.NONE)
	assert_eq(
		DartEnum.names(CombatRole.Value),
		PackedStringArray(["none", "taunt", "bossBreaker", "armourPiercer", "evasive"])
	)

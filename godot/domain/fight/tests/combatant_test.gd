extends TestCase
## test/domain/fight/combatant_test.dart: one fighter of a fight.

const PLAYER := CombatSide.Value.PLAYER
const MONSTER := CombatSide.Value.MONSTER


func _c(key: String, side: CombatSide.Value) -> Combatant:
	return Combatant.new(side, key, 10, 1, 1)


func test_combatant_defaults_current_hp_to_max_hp() -> void:
	var c := Combatant.new(PLAYER, "scout", 12, 3, 1)
	assert_eq(c.current_hp, 12)
	assert_true(c.is_alive())


func test_combatant_is_boss_defaults_to_false() -> void:
	var c := Combatant.new(PLAYER, "scout", 10, 3, 1)
	assert_false(c.is_boss)


func test_combatant_is_boss_can_be_set_to_true() -> void:
	var c := Combatant.new(MONSTER, "boss", 100, 20, 10, null, true)
	assert_true(c.is_boss)


func test_combatant_apply_damage_drops_hp_and_returns_amount_applied() -> void:
	var c := Combatant.new(PLAYER, "scout", 10, 3, 1)
	var applied := c.apply_damage(3)
	assert_eq(applied, 3)
	assert_eq(c.current_hp, 7)
	assert_true(c.is_alive())


func test_combatant_apply_damage_clamps_hp_at_0_and_returns_applied_delta() -> void:
	var c := Combatant.new(MONSTER, "monsterL2", 5, 4, 2)
	var applied := c.apply_damage(8)
	assert_eq(applied, 5)
	assert_eq(c.current_hp, 0)
	assert_false(c.is_alive())


func test_combatant_is_alive_becomes_false_when_hp_hits_0() -> void:
	var c := Combatant.new(PLAYER, "scout", 4, 1, 0)
	c.apply_damage(4)
	assert_eq(c.current_hp, 0)
	assert_false(c.is_alive())


func test_combatant_role_is_the_combat_role_of_its_type_key() -> void:
	assert_eq(_c("guardian", PLAYER).role, CombatRole.Value.TAUNT)
	assert_eq(_c(CombatRole.RAMPART_KEY, PLAYER).role, CombatRole.Value.TAUNT)
	assert_eq(_c("guardian", MONSTER).role, CombatRole.Value.TAUNT)
	assert_eq(_c("monsterL1", MONSTER).role, CombatRole.Value.NONE)
	assert_eq(_c("hunterL2", MONSTER).role, CombatRole.Value.NONE)


func test_combatant_family_is_the_monster_family_of_its_type_key() -> void:
	assert_eq(_c("hunterL2", MONSTER).family, MonsterFamily.Value.HUNTER)
	assert_null(_c("monsterL1", MONSTER).family)
	assert_null(_c("guardian", PLAYER).family)


## Not in the Dart file: a wounded fighter keeps the health it is given, and
## a blow of nothing or less does nothing.
func test_combatant_takes_the_health_it_is_given() -> void:
	var c := Combatant.new(PLAYER, "scout", 10, 3, 1, 4)
	assert_eq(c.current_hp, 4)
	assert_eq(c.apply_damage(0), 0)
	assert_eq(c.apply_damage(-3), 0)
	assert_eq(c.current_hp, 4)
	assert_eq(Combatant.new(PLAYER, "scout", 10, 3, 1, 0).current_hp, 0)

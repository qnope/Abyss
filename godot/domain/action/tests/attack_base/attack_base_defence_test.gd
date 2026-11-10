extends TestCase
## test/domain/action/attack_base/attack_base_defence_test.dart: who defends
## a base, its rampart, and where the survivors of both sides go.

const GUARDIAN := UnitType.Value.GUARDIAN
const HARPOONIST := UnitType.Value.HARPOONIST
const HQ := BuildingType.Value.HEADQUARTERS
const CITADEL := BuildingType.Value.CORAL_CITADEL


func _fight(game: Game, army: Dictionary[UnitType.Value, int] = AssaultSamples.HORDE) -> AttackBaseResult:
	AssaultSamples.station(game.human_player(), army)
	var result: AttackBaseResult = AssaultSamples.strike(game, army).execute(game, game.human_player())
	return result


func _fortified(hq: int) -> Game:
	var game := AssaultSamples.assault_game()
	var rival := AssaultSamples.rival_of(game)
	AssaultSamples.set_level(rival, CITADEL, 3)
	AssaultSamples.set_level(rival, HQ, hq)
	return game


func test_the_defenders_are_the_units_standing_on_the_base_level() -> void:
	var game := AssaultSamples.assault_game()
	var rival := AssaultSamples.rival_of(game)
	AssaultSamples.station(rival, {GUARDIAN: 4, HARPOONIST: 6})
	var deeper: Dictionary[UnitType.Value, Unit] = {HARPOONIST: Unit.new(HARPOONIST, 50)}
	rival.units_per_level[2] = deeper
	var result := _fight(game)
	assert_eq(result.defence.engaged, {GUARDIAN: 4, HARPOONIST: 6})
	assert_eq(result.defence.initial.size(), 10)
	assert_true(result.defence.initial.all(func(c: Combatant) -> bool: return c.side == CombatSide.Value.MONSTER))


func test_the_citadel_rampart_defends_beside_the_units() -> void:
	var game := _fortified(10)
	var result := _fight(game)
	assert_eq(result.defence.initial.size(), 1)
	var rampart := result.defence.initial[0]
	assert_eq(rampart.type_key, "rampart")
	assert_eq(rampart.max_hp, 120)
	assert_eq(rampart.def, 7)
	assert_eq(result.fight.final_monster_count, 0)


func test_a_degraded_citadel_defends_with_half_of_its_force() -> void:
	var strong := _fight(_fortified(10)).defence.initial[0]
	var weak := _fight(_fortified(1)).defence.initial[0]
	assert_eq(weak.max_hp, DartMath.trunc_div(strong.max_hp, 2))
	assert_eq(weak.def, DartMath.trunc_div(strong.def, 2))


func test_the_attackers_leave_the_base_and_the_survivors_come_home() -> void:
	var game := AssaultSamples.assault_game()
	var result := _fight(game)
	var home := AssaultSamples.standing(game.human_player(), HARPOONIST)
	assert_eq(result.sent, {HARPOONIST: 40})
	assert_eq(home, 40 - result.dead.get(HARPOONIST, 0))
	assert_true(result.victory)


func test_defenders_that_fall_are_wounded_or_dead_the_rest_stay_home() -> void:
	var game := AssaultSamples.assault_game()
	var rival := AssaultSamples.rival_of(game)
	AssaultSamples.station(rival, {HARPOONIST: 10})
	var result := _fight(game, {HARPOONIST: 60})
	var lost: int = result.defence.dead.get(HARPOONIST, 0)
	var wounded: int = result.defence.wounded.get(HARPOONIST, 0)
	assert_eq(lost + wounded, 10)
	assert_eq(AssaultSamples.standing(rival, HARPOONIST), 10 - lost)


func test_an_empty_base_falls_without_a_fight() -> void:
	var result := _fight(AssaultSamples.assault_game())
	assert_true(result.victory)
	assert_eq(result.fight.turn_count, 0)

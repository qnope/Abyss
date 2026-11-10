extends TestCase
## test/domain/action/fight_monster_result_test.dart: the outcome of a fight
## against a lair.


func test_failure_exposes_is_success_false_and_empty_maps() -> void:
	var result := FightMonsterResult.failure(ActionFailure.Value.LAIR_EMPTY)
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.LAIR_EMPTY)
	assert_false(result.victory)
	assert_null(result.fight)
	for map: Dictionary in [result.loot, result.sent, result.survivors_intact, result.wounded, result.dead]:
		assert_true(map.is_empty())


func test_success_preserves_all_fields_and_victory_flag() -> void:
	var fight := FightResult.new(CombatSide.Value.PLAYER, 3, [], [], [], 4, 0)
	var loot: Dictionary[ResourceType.Value, int] = {
		ResourceType.Value.ALGAE: 12, ResourceType.Value.ORE: 4
	}
	var sent: Dictionary[UnitType.Value, int] = {
		UnitType.Value.SCOUT: 3, UnitType.Value.HARPOONIST: 2
	}
	var intact: Dictionary[UnitType.Value, int] = {UnitType.Value.SCOUT: 2}
	var wounded: Dictionary[UnitType.Value, int] = {UnitType.Value.HARPOONIST: 1}
	var dead: Dictionary[UnitType.Value, int] = {
		UnitType.Value.SCOUT: 1, UnitType.Value.HARPOONIST: 1
	}

	var result := FightMonsterResult.success(true, fight, loot, sent, intact, wounded, dead)

	assert_true(result.is_success)
	assert_null(result.reason)
	assert_true(result.victory)
	assert_true(result.fight == fight)
	assert_eq(result.loot, loot)
	assert_eq(result.sent, sent)
	assert_eq(result.survivors_intact, intact)
	assert_eq(result.wounded, wounded)
	assert_eq(result.dead, dead)


func test_is_assignable_to_an_action_result_variable() -> void:
	var fight := FightMonsterResult.failure(ActionFailure.Value.LAIR_EMPTY)
	var result: ActionResult = fight
	assert_false(result.is_success)


## Not in the Dart file: the breakdown the helpers hand to a fight action.
func test_a_casualty_breakdown_keeps_its_three_maps() -> void:
	var intact: Dictionary[UnitType.Value, int] = {UnitType.Value.SCOUT: 2}
	var wounded: Dictionary[UnitType.Value, int] = {UnitType.Value.GUARDIAN: 1}
	var dead: Dictionary[UnitType.Value, int] = {}
	var breakdown := FightCasualtyBreakdown.new(intact, wounded, dead)
	assert_eq([breakdown.survivors_intact, breakdown.wounded, breakdown.dead], [intact, wounded, dead])

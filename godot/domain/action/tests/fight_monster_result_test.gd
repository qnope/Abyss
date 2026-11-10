extends TestCase
## test/domain/action/fight_monster_result_test.dart: the outcome of a fight
## against a lair. 'success preserves all fields and victory flag' without
## its isSuccess and reason; 'failure exposes isSuccess false and empty maps'
## and 'is assignable to an ActionResult variable' wait for the action
## module (ActionResult, ActionFailure).


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

	assert_true(result.victory)
	assert_true(result.fight == fight)
	assert_eq(result.loot, loot)
	assert_eq(result.sent, sent)
	assert_eq(result.survivors_intact, intact)
	assert_eq(result.wounded, wounded)
	assert_eq(result.dead, dead)


## Not in the Dart file: the breakdown the helpers hand to a fight action.
func test_a_casualty_breakdown_keeps_its_three_maps() -> void:
	var intact: Dictionary[UnitType.Value, int] = {UnitType.Value.SCOUT: 2}
	var wounded: Dictionary[UnitType.Value, int] = {UnitType.Value.GUARDIAN: 1}
	var dead: Dictionary[UnitType.Value, int] = {}
	var breakdown := FightCasualtyBreakdown.new(intact, wounded, dead)
	assert_eq([breakdown.survivors_intact, breakdown.wounded, breakdown.dead], [intact, wounded, dead])

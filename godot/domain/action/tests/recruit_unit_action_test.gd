extends TestCase
## test/domain/action/recruit_unit_action_test.dart: recruiting units at
## the barracks.

const SCOUT := UnitType.Value.SCOUT


func _scenario(algae := 100, barracks_level := 1, recruited: Array[UnitType.Value] = []) -> Player:
	return ActionSamples.stocked(
		ActionSamples.amounts(algae, 100, 100, 100, 100), {BuildingType.Value.BARRACKS: barracks_level}, recruited
	)


func _validate(player: Player, type := SCOUT, quantity := 1) -> ActionResult:
	return RecruitUnitAction.new(type, quantity).validate(ActionSamples.game_of(player), player)


func _execute(player: Player, type := SCOUT, quantity := 1) -> ActionResult:
	return RecruitUnitAction.new(type, quantity).execute(ActionSamples.game_of(player), player)


func test_validate_success_with_valid_conditions() -> void:
	assert_true(_validate(_scenario()).is_success)


func test_validate_fails_when_unit_is_locked() -> void:
	assert_eq(_validate(_scenario(100, 0)).reason, ActionFailure.Value.UNIT_LOCKED)


func test_validate_fails_when_already_recruited_this_type() -> void:
	var recruited: Array[UnitType.Value] = [SCOUT]
	assert_eq(_validate(_scenario(100, 1, recruited)).reason, ActionFailure.Value.RECRUITMENT_ALREADY_DONE)


func test_validate_fails_with_insufficient_resources() -> void:
	assert_eq(_validate(_scenario(5)).reason, ActionFailure.Value.NOT_ENOUGH_RESOURCES)


func test_validate_fails_with_zero_quantity() -> void:
	assert_eq(_validate(_scenario(), SCOUT, 0).reason, ActionFailure.Value.INVALID_QUANTITY)


func test_validate_fails_for_guardian_at_barracks_2() -> void:
	assert_false(_validate(_scenario(100, 2), UnitType.Value.GUARDIAN).is_success)


func test_execute_deducts_resources() -> void:
	var player := _scenario()
	_execute(player)
	assert_eq(player.resources[ResourceType.Value.ALGAE].amount, 90)
	assert_eq(player.resources[ResourceType.Value.CORAL].amount, 95)


func test_execute_adds_units() -> void:
	var player := _scenario()
	_execute(player, SCOUT, 3)
	assert_eq(player.units_on_level(1)[SCOUT].count, 3)


func test_execute_marks_recruited() -> void:
	var player := _scenario()
	_execute(player)
	assert_has(player.recruited_unit_types, SCOUT)


func test_execute_multiple_types_in_same_turn() -> void:
	var player := _scenario()
	_execute(player)
	assert_true(_execute(player, UnitType.Value.HARPOONIST).is_success)


func test_execute_same_type_twice_fails() -> void:
	var player := _scenario()
	_execute(player)
	assert_false(_execute(player).is_success)


func test_via_action_executor_executor_validates_then_executes() -> void:
	var player := _scenario()
	var result := ActionExecutor.new().execute(RecruitUnitAction.new(SCOUT, 2), ActionSamples.game_of(player), player)
	assert_true(result.is_success)
	assert_eq(player.units_on_level(1)[SCOUT].count, 2)


## Not in the Dart file: each recruit is noise, and the description names
## the Dart value.
func test_each_recruit_is_noise() -> void:
	var player := _scenario()
	var action := RecruitUnitAction.new(SCOUT, 2)
	assert_eq([action.noise_made(player), action.type()], [2, ActionType.Value.RECRUIT_UNIT])
	assert_eq(action.description(), "Recruter 2 UnitType.scout")

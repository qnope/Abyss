extends TestCase
## test/domain/volcano/garrison_kernel_action_test.dart: units shut into the
## kernel's garrison, or taken back out.

const HARPOONIST := UnitType.Value.HARPOONIST
const GUARDIAN := UnitType.Value.GUARDIAN


func _action(selected: Dictionary[UnitType.Value, int], withdraw := false) -> GarrisonKernelAction:
	return GarrisonKernelAction.new(selected, withdraw)


func test_moves_units_of_the_volcano_level_into_the_garrison() -> void:
	var player := RaidSamples.volcano_player(1, {}, {HARPOONIST: 10})
	var game := MoveSamples.volcano_game(player)
	var result := _action({HARPOONIST: 6}).execute(game, player)
	assert_true(result.is_success)
	assert_eq(KernelGarrison.of(player), {HARPOONIST: 6})
	assert_eq(player.units_on_level(3)[HARPOONIST].count, 4)


func test_withdraws_units_back_to_the_volcano_level() -> void:
	var player := RaidSamples.volcano_player(1, {GUARDIAN: 5})
	var game := MoveSamples.volcano_game(player)
	_action({GUARDIAN: 2}, true).execute(game, player)
	assert_eq(KernelGarrison.size_of(player), 3)
	assert_eq(player.units_on_level(3)[GUARDIAN].count, 2)


func test_refuses_more_units_than_there_are() -> void:
	var player := RaidSamples.volcano_player(1, {}, {HARPOONIST: 1})
	var result := _action({HARPOONIST: 2}).validate(MoveSamples.volcano_game(player), player)
	assert_false(result.is_success)


func test_refuses_while_the_kernel_is_not_captured() -> void:
	var player := RaidSamples.volcano_player(1, {}, {HARPOONIST: 4})
	var result := _action({HARPOONIST: 2}).validate(MoveSamples.volcano_game(player, false), player)
	assert_eq(result.reason, ActionFailure.Value.KERNEL_NOT_CAPTURED)


## Not in the Dart file: the kernel must stand to take a garrison, the
## types of none are skipped, a choice of none is refused, and the French
## descriptions.
func test_a_garrison_needs_a_kernel_and_units() -> void:
	var player := RaidSamples.volcano_player(0, {}, {HARPOONIST: 4})
	var game := MoveSamples.volcano_game(player)
	assert_eq(_action({HARPOONIST: 1}).validate(game, player).reason, ActionFailure.Value.KERNEL_NOT_BUILT)
	assert_eq(_action({HARPOONIST: 1}, true).validate(game, player).reason, ActionFailure.Value.NOT_ENOUGH_UNITS)
	player.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 1
	assert_eq(_action({HARPOONIST: 0, GUARDIAN: -1}).validate(game, player).reason, ActionFailure.Value.NO_UNIT_SELECTED)
	assert_true(_action({GUARDIAN: 0, HARPOONIST: 3}).execute(game, player).is_success)
	assert_eq(KernelGarrison.of(player), {HARPOONIST: 3})
	var garrison := _action({})
	assert_eq([garrison.type(), garrison.description()], [ActionType.Value.GARRISON_KERNEL, "Mettre en garnison"])
	assert_eq(_action({}, true).description(), "Retirer de la garnison")

extends TestCase
## test/domain/raid/action_noise_test.dart: the noise of the actions.


func _execute(player: Player, action: Action) -> void:
	ActionExecutor.new().execute(action, Game.single_player(player), player)


func test_recruiting_makes_one_noise_per_unit() -> void:
	var player := RaidSamples.raid_player()
	player.buildings[BuildingType.Value.BARRACKS] = Building.new(BuildingType.Value.BARRACKS, 1)
	_execute(player, RecruitUnitAction.new(UnitType.Value.HARPOONIST, 4))
	assert_eq(player.raid_state.noise, 4)


func test_upgrading_makes_as_much_noise_as_the_level_reached() -> void:
	var player := RaidSamples.raid_player()
	player.buildings[BuildingType.Value.HEADQUARTERS] = Building.new(BuildingType.Value.HEADQUARTERS, 2)
	_execute(player, UpgradeBuildingAction.new(BuildingType.Value.HEADQUARTERS))
	assert_eq(player.raid_state.noise, 3)


func test_each_kernel_level_makes_the_noise_of_its_level() -> void:
	assert_eq(NoiseRules.for_upgrade(BuildingType.Value.VOLCANIC_KERNEL, 3), 3)
	assert_eq(NoiseRules.for_upgrade(BuildingType.Value.HEADQUARTERS, 3), 3)


func test_a_failed_action_makes_no_noise() -> void:
	var player := RaidSamples.raid_player()
	_execute(player, RecruitUnitAction.new(UnitType.Value.HARPOONIST, 0))
	assert_eq(player.raid_state.noise, 0)


## Not in the Dart file: the tuning of the gauge, as noise_rules.dart says.
func test_the_gauge_is_tuned_as_in_dart() -> void:
	assert_eq(
		[
			NoiseRules.THRESHOLD, NoiseRules.PER_TURN, NoiseRules.PER_RECRUIT,
			NoiseRules.PER_EXPLORATION, NoiseRules.PER_FIGHT, NoiseRules.WARNING_TURNS,
			NoiseRules.FIRST_RAID_TURN, NoiseRules.KERNEL_UPGRADE_FACTOR,
		],
		[40, 3, 1, 1, 3, 2, 10, 1],
	)

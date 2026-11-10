extends TestCase
## test/domain/raid/action_noise_test.dart: the noise of the actions. 'each
## kernel level makes the noise of its level'; 'recruiting makes one noise
## per unit', 'upgrading makes as much noise as the level reached' and 'a
## failed action makes no noise' execute actions and wait for the action
## module (ActionExecutor).


func test_each_kernel_level_makes_the_noise_of_its_level() -> void:
	assert_eq(NoiseRules.for_upgrade(BuildingType.Value.VOLCANIC_KERNEL, 3), 3)
	assert_eq(NoiseRules.for_upgrade(BuildingType.Value.HEADQUARTERS, 3), 3)


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

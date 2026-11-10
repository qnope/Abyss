extends TestCase
## test/domain/game/difficulty_world_relief_test.dart: the monsters ease on
## the human as the world grows with the factions.

const NORMAL := Difficulty.Value.NORMAL


func test_a_game_without_faction_keeps_the_monsters_it_always_had() -> void:
	assert_eq(Difficulty.world_relief_percent(0), 100)
	assert_eq(Difficulty.monster_percent_for(NORMAL, false), 94)


func test_the_more_factions_the_bigger_the_world_and_the_lighter_the_raids() -> void:
	var reliefs: Array[int] = []
	for factions: int in [0, 1, 3, 5, 10]:
		reliefs.append(Difficulty.world_relief_percent(factions))
	assert_eq(reliefs, [100, 97, 92, 87, 75])


func test_the_relief_eases_the_human_only_never_a_faction() -> void:
	assert_eq(Difficulty.monster_percent_for(NORMAL, false, 3), DartMath.trunc_div(94 * 92, 100))
	assert_eq(
		Difficulty.monster_percent_for(NORMAL, true, 3),
		Difficulty.monster_percent_for(NORMAL, true)
	)


func test_a_raid_on_the_human_is_smaller_in_a_world_of_ten_factions() -> void:
	assert_true(_raid_size(10) < _raid_size(0))


func test_a_kraken_wave_on_the_human_kernel_is_lighter_too() -> void:
	assert_true(_krakens(10) < _krakens(0))


func _raid_size(factions: int) -> int:
	var player := RaidSamples.raid_player()
	player.raid_state.add_noise(NoiseRules.THRESHOLD)
	player.raid_state.total_noise = 4000
	var outcome := RaidResolver.resolve(player, 12, DartRandom.new(1), NORMAL, false, factions)
	return outcome.announced.unit_count


func _krakens(factions: int) -> int:
	var player := RaidSamples.raid_player()
	player.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 9
	return VolcanoResolver.resolve(player, 12, null, NORMAL, false, factions).announced.unit_count

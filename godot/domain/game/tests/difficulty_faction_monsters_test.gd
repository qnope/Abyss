extends TestCase
## test/domain/game/difficulty_faction_monsters_test.dart: the monsters
## spare the factions.


func test_monsters_spend_three_quarters_of_their_strength_on_a_faction() -> void:
	assert_eq(Difficulty.monster_percent_for(Difficulty.Value.NORMAL, false), 94)
	assert_eq(Difficulty.monster_percent_for(Difficulty.Value.NORMAL, true), 70)
	assert_eq(Difficulty.monster_percent_for(Difficulty.Value.EASY, true), 64)
	assert_eq(Difficulty.monster_percent_for(Difficulty.Value.HARD, true), 76)


func test_a_raid_on_a_faction_is_weaker_than_the_same_raid_on_the_human() -> void:
	assert_true(_raid_size(true) < _raid_size(false))


func test_a_kraken_wave_on_a_faction_kernel_is_weaker_too() -> void:
	assert_true(_krakens(true) < _krakens(false))


func _raid_size(faction: bool) -> int:
	var player := RaidSamples.raid_player()
	player.raid_state.add_noise(NoiseRules.THRESHOLD)
	player.raid_state.total_noise = 4000
	var outcome := RaidResolver.resolve(
		player, 12, DartRandom.new(1), Difficulty.Value.NORMAL, faction
	)
	return outcome.announced.unit_count


func _krakens(faction: bool) -> int:
	var player := RaidSamples.raid_player()
	player.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 9
	var outcome := VolcanoResolver.resolve(player, 12, null, Difficulty.Value.NORMAL, faction)
	return outcome.announced.unit_count

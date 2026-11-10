extends TestCase
## test/domain/raid/raid_attack_collision_test.dart: a raid never lands on
## the turn of an attack of a faction.


func _attack_for(turn: int) -> AnnouncedAttack:
	return AnnouncedAttack.new("faction-x", {UnitType.Value.HARPOONIST: 5}, turn, 1)


func test_a_raid_announced_for_the_turn_of_an_attack_comes_a_turn_later() -> void:
	var player := RaidSamples.raid_player()
	player.raid_state.attacks.append(_attack_for(14))
	player.raid_state.noise = NoiseRules.THRESHOLD

	var outcome := RaidResolver.resolve(player, 12)

	assert_not_null(outcome.announced)
	assert_eq(outcome.announced_turn, 15)
	assert_eq(player.raid_state.arrival_turn, 15)


func test_a_raid_announced_for_any_other_turn_keeps_its_date() -> void:
	var player := RaidSamples.raid_player()
	player.raid_state.attacks.append(_attack_for(13))
	player.raid_state.noise = NoiseRules.THRESHOLD

	assert_eq(RaidResolver.resolve(player, 12).announced_turn, 14)

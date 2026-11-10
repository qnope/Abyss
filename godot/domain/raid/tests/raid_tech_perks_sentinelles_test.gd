extends TestCase
## test/domain/raid/raid_tech_perks_test.dart, group 'Sentinelles': the
## research that warns of a raid sooner.

const A := TechOption.Value.A
const B := TechOption.Value.B


func _gauged_with_explorer(options: Array[TechOption.Value]) -> Player:
	var player := RaidSamples.raid_player()
	player.tech_branches[TechBranch.Value.EXPLORER] = TechHelpers.researched_branch(
		TechBranch.Value.EXPLORER, 4, options
	)
	player.raid_state.add_noise(NoiseRules.THRESHOLD)
	return player


func test_sentinelles_a_raid_is_announced_four_turns_ahead() -> void:
	var player := _gauged_with_explorer([A, B])
	var outcome := RaidResolver.resolve(player, 12)

	assert_eq(outcome.announced_turn, 16)
	assert_eq(player.raid_state.arrival_turn, 16)


func test_sentinelles_pillards_d_epaves_keeps_the_two_turn_warning() -> void:
	var player := _gauged_with_explorer([A, A])

	assert_eq(RaidResolver.resolve(player, 12).announced_turn, 14)

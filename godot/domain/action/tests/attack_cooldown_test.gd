extends TestCase
## Not in the Dart files: lib/domain/action/attack_cooldown.dart, which
## attack_post_cooldown_test.dart and attack_held_kernel_cooldown_test.dart
## read through the attacks: four turns between two attacks of one attacker
## on one target, posts and kernel apart.


func test_an_attacker_waits_four_turns_on_the_same_target() -> void:
	var game := AssaultSamples.assault_game(12)
	var attacker := game.human_player()
	var owner := AssaultSamples.rival_of(game)
	assert_false(AttackCooldown.on_posts(game, attacker, owner))
	AttackCooldown.post_attacked(10, attacker, owner)
	assert_true(AttackCooldown.on_posts(game, attacker, owner))
	assert_false(AttackCooldown.on_kernel(game, attacker, owner))
	assert_false(AttackCooldown.on_posts(game, owner, attacker))
	game.turn = 14
	assert_false(AttackCooldown.on_posts(game, attacker, owner))
	AttackCooldown.kernel_attacked(11, attacker, owner)
	assert_true(AttackCooldown.on_kernel(game, attacker, owner))
	assert_eq([attacker.raid_state.post_attack_turns, attacker.raid_state.kernel_attack_turns], [{"rival-1": 10}, {"rival-1": 11}])

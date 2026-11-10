extends TestCase
## Not in the Dart file (test/domain/raid/raid_state_test.dart): what the
## Dart tests of the raids, of the attacks of the factions and of the
## replays hold of RaidState and AnnouncedAttack, here before them. The
## answers are those of lib/domain/raid/raid_state.dart.


func test_a_new_state_is_quiet_and_holds_nothing() -> void:
	var state := RaidState.new()
	assert_eq([state.noise, state.total_noise, state.lost_in_a_row], [0, 0, 0])
	assert_eq([state.raids_repelled, state.raids_lost], [0, 0])
	assert_eq([state.incoming, state.arrival_turn], [null, null])
	assert_null(state.kernel_siege_lost_turn)
	assert_false(state.is_incoming())
	assert_eq(state.attacks, [] as Array[AnnouncedAttack])
	assert_eq(state.post_attack_turns, {} as Dictionary[String, int])
	assert_eq(state.kernel_attack_turns, {} as Dictionary[String, int])


func test_takes_its_fields_in_the_dart_order() -> void:
	var wave := MonsterLair.new(MonsterDifficulty.Value.EASY, 8)
	var attacks: Array[AnnouncedAttack] = [_attack("faction-pearlOrder", 9)]
	var posts: Dictionary[String, int] = {"a": 3}
	var kernels: Dictionary[String, int] = {"b": 4}
	var state := RaidState.new(1, 2, wave, 12, 3, 4, 5, attacks, 6, posts, kernels)
	assert_eq([state.noise, state.total_noise], [1, 2])
	assert_eq([state.incoming, state.arrival_turn], [wave, 12])
	assert_eq([state.lost_in_a_row, state.raids_repelled, state.raids_lost], [3, 4, 5])
	assert_eq([state.attacks, state.kernel_siege_lost_turn], [attacks, 6])
	assert_eq([state.post_attack_turns, state.kernel_attack_turns], [posts, kernels])


func test_a_wave_without_its_turn_is_not_incoming() -> void:
	var wave := MonsterLair.new(MonsterDifficulty.Value.EASY, 8)
	assert_false(RaidState.new(0, 0, wave).is_incoming())
	assert_false(RaidState.new(0, 0, null, 12).is_incoming())


func test_a_raid_repelled_resets_the_raids_lost_in_a_row() -> void:
	var state := RaidState.new()
	state.record_outcome(false)
	state.record_outcome(false)
	assert_eq([state.raids_lost, state.lost_in_a_row, state.raids_repelled], [2, 2, 0])
	state.record_outcome(true)
	assert_eq([state.raids_lost, state.lost_in_a_row, state.raids_repelled], [2, 0, 1])


func test_tells_the_attacks_announced_by_their_sender_and_their_turn() -> void:
	var state := RaidState.new()
	assert_false(state.has_attack_from("faction-pearlOrder"))
	assert_false(state.is_attacked_on(9))
	state.attacks.append(_attack("faction-pearlOrder", 9))
	assert_true(state.has_attack_from("faction-pearlOrder"))
	assert_false(state.has_attack_from("faction-anglerCult"))
	assert_true(state.is_attacked_on(9))
	assert_false(state.is_attacked_on(10))


func test_an_announced_attack_keeps_its_army_its_turn_and_its_dice() -> void:
	var attack := _attack("faction-pearlOrder", 9)
	assert_eq([attack.attacker_id, attack.arrival_turn], ["faction-pearlOrder", 9])
	assert_eq(attack.fight_seed, 77)
	assert_eq(attack.units, {UnitType.Value.HARPOONIST: 12} as Dictionary[UnitType.Value, int])


func test_two_states_keep_their_own_attacks_and_cool_downs() -> void:
	var first := RaidState.new()
	first.attacks.append(_attack("faction-pearlOrder", 9))
	first.post_attack_turns["a"] = 3
	first.kernel_attack_turns["a"] = 4
	var second := RaidState.new()
	assert_eq(second.attacks.size(), 0)
	assert_eq([second.post_attack_turns.size(), second.kernel_attack_turns.size()], [0, 0])


func _attack(attacker_id: String, arrival_turn: int) -> AnnouncedAttack:
	return AnnouncedAttack.new(attacker_id, {UnitType.Value.HARPOONIST: 12}, arrival_turn, 77)

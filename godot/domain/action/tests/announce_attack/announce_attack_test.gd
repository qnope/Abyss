extends TestCase
## test/domain/action/announce_attack/announce_attack_test.dart: a faction
## decides an attack on the human base.

const HARPOONIST := UnitType.Value.HARPOONIST


func _reason(game: Game, player: Player, army := AssaultSamples.RAIDERS) -> Variant:
	return AssaultSamples.announce(army).validate(game, player).reason


func _rival(game: Game) -> Player:
	return AssaultSamples.rival_of(game)


func test_an_attack_lands_at_the_end_of_the_turn_it_is_decided_without_warning() -> void:
	var game := AssaultSamples.announce_game()
	var result := AssaultSamples.announce({HARPOONIST: 25}).execute(game, _rival(game))
	assert_true(result.is_success)
	var pending := game.human_player().raid_state.attacks
	assert_eq(pending.size(), 1)
	assert_eq(pending[0].attacker_id, _rival(game).id)
	assert_eq(pending[0].arrival_turn, 12)
	assert_eq(pending[0].units, {HARPOONIST: 25} as Dictionary[UnitType.Value, int])


func test_the_army_stays_on_the_base_until_the_attack() -> void:
	var game := AssaultSamples.announce_game()
	AssaultSamples.announce({HARPOONIST: 25}).execute(game, _rival(game))
	assert_eq(AssaultSamples.standing(_rival(game), HARPOONIST), 40)


func test_nothing_is_announced_while_the_tutorial_is_unfinished() -> void:
	var game := AssaultSamples.announce_game()
	ObjectiveMigration.state_of(game, game.human_player()).tutorial_enabled = true
	assert_eq(_reason(game, _rival(game)), ActionFailure.Value.ATTACK_TOO_EARLY)


func test_without_a_tutorial_nothing_is_announced_before_turn_10() -> void:
	var early := AssaultSamples.announce_game(9)
	var ready := AssaultSamples.announce_game(10)
	assert_eq(_reason(early, _rival(early)), ActionFailure.Value.ATTACK_TOO_EARLY)
	assert_true(AssaultSamples.announce().validate(ready, _rival(ready)).is_success)


func test_no_attack_is_announced_for_the_turn_a_monster_raid_hits() -> void:
	var game := AssaultSamples.announce_game()
	game.human_player().raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.EASY, 3), 12)
	assert_eq(_reason(game, _rival(game)), ActionFailure.Value.RAID_SAME_TURN)


func test_a_raid_on_another_turn_does_not_stand_in_the_way() -> void:
	var game := AssaultSamples.announce_game()
	game.human_player().raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.EASY, 3), 15)
	assert_true(AssaultSamples.announce().validate(game, _rival(game)).is_success)


func test_a_faction_has_one_pending_attack_at_a_time() -> void:
	var game := AssaultSamples.announce_game()
	AssaultSamples.announce({HARPOONIST: 10}).execute(game, _rival(game))
	assert_eq(_reason(game, _rival(game), {HARPOONIST: 10}), ActionFailure.Value.ATTACK_ALREADY_ANNOUNCED)


func test_the_human_cannot_announce_an_attack_on_itself() -> void:
	var game := AssaultSamples.announce_game()
	AssaultSamples.station(game.human_player(), AssaultSamples.RAIDERS)
	assert_eq(_reason(game, game.human_player()), ActionFailure.Value.CANNOT_ATTACK_SELF)


func test_units_the_base_does_not_hold_cannot_be_announced() -> void:
	var game := AssaultSamples.announce_game()
	assert_eq(_reason(game, _rival(game), {HARPOONIST: 41}), ActionFailure.Value.NOT_ENOUGH_UNITS)


func test_the_announcement_never_counts_as_a_fight_for_the_rival() -> void:
	var game := AssaultSamples.announce_game()
	AssaultSamples.announce().execute(game, _rival(game))
	assert_eq(AssaultSamples.announce().noise_made(_rival(game)), 0)
	assert_true(game.human_player().history_entries.is_empty())


## Not in the Dart file: what names the action, the seed of the fight, the
## units left out, and a refusal that announces nothing.
func test_the_seed_of_the_fight_and_the_units_sent() -> void:
	var game := AssaultSamples.announce_game()
	var action := AnnounceAttackAction.new({UnitType.Value.GUARDIAN: 0, HARPOONIST: 7}, DartRandom.new(41))
	assert_eq(action.type(), ActionType.Value.ANNOUNCE_ATTACK)
	assert_eq(action.description(), "Annonce une attaque sur la base du joueur")
	assert_eq(action.execute(game, game.human_player()).reason, ActionFailure.Value.CANNOT_ATTACK_SELF)
	assert_true(game.human_player().raid_state.attacks.is_empty())
	assert_true(action.execute(game, _rival(game)).is_success)
	var attack := game.human_player().raid_state.attacks[0]
	assert_eq(attack.fight_seed, 41)
	assert_eq(attack.units, {HARPOONIST: 7} as Dictionary[UnitType.Value, int])
	var other := AssaultSamples.announce_game(12, "rival-2")
	assert_true(AnnounceAttackAction.new({HARPOONIST: 7}).execute(other, _rival(other)).is_success)
	var drawn := other.human_player().raid_state.attacks[0].fight_seed
	assert_true(drawn >= 0 and drawn < 0x7FFFFFFF)


## Not in the Dart file: a raid turn left without a wave holds nothing back.
func test_a_raid_turn_without_a_wave_does_not_stand_in_the_way() -> void:
	var game := AssaultSamples.announce_game()
	game.human_player().raid_state.arrival_turn = 12
	assert_null(_reason(game, _rival(game)))

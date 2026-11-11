extends TestCase
## test/domain/action/announce_attack/announced_attack_resolve_test.dart:
## the attacks announced on the base, fought at the end of the turn.

const HARPOONIST := UnitType.Value.HARPOONIST
const HQ := BuildingType.Value.HEADQUARTERS


static func _end_turn(game: Game) -> void:
	EndTurnAction.new(DartRandom.new(1), false).execute(game, game.human_player())


static func _assaults(p: Player) -> Array[BaseAssaultEntry]:
	var found: Array[BaseAssaultEntry] = []
	for e: HistoryEntry in p.history_entries:
		if e is BaseAssaultEntry:
			found.append(e)
	return found


## The game of `announceGame` whose rival announced its attack, the human
## base standing bare when `bare`.
static func _announced(bare := true) -> Game:
	var game := AssaultSamples.announce_game()
	if bare:
		AssaultSamples.station(game.human_player(), {})
	AssaultSamples.announce().execute(game, AssaultSamples.rival_of(game))
	return game


func test_the_attack_is_fought_at_the_end_of_the_turn_it_is_decided() -> void:
	var game := _announced()

	_end_turn(game)

	var entries := _assaults(game.human_player())
	assert_eq(entries.size(), 1)
	assert_eq(entries[0].turn, 12)
	assert_true(game.human_player().raid_state.attacks.is_empty())
	assert_eq(game.turn, 13)


func test_the_units_standing_on_the_human_base_when_the_turn_ends_defend() -> void:
	var game := _announced()
	AssaultSamples.station(game.human_player(), AssaultSamples.WALL)

	_end_turn(game)

	var entry := _assaults(game.human_player())[0]
	assert_true(entry.defending)
	assert_false(entry.victory)
	assert_eq(entry.units, AssaultSamples.WALL)


func test_a_won_attack_razes_the_base_and_pillages_it_like_any_attack() -> void:
	var game := _announced()
	var hq := game.human_player().buildings[HQ].level

	_end_turn(game)

	var entry := _assaults(game.human_player())[0]
	assert_true(entry.victory)
	assert_true(entry.headquarters_after < hq)
	assert_eq(game.human_player().buildings[HQ].level, hq - 1)


func test_the_attacker_keeps_a_history_entry_and_its_survivors() -> void:
	var game := _announced()

	_end_turn(game)

	var rival := AssaultSamples.rival_of(game)
	var mine := _assaults(rival)
	assert_eq(mine.size(), 1)
	assert_false(mine[0].defending)
	var standing := AssaultSamples.standing(rival, HARPOONIST)
	assert_true(standing >= 1 and standing <= 40, str(standing))


func test_a_lost_attack_costs_the_army_and_spares_the_base() -> void:
	var game := _announced()
	var hq := game.human_player().buildings[HQ].level

	AssaultSamples.station(game.human_player(), AssaultSamples.WALL)
	_end_turn(game)

	assert_eq(game.human_player().buildings[HQ].level, hq)
	assert_true(AssaultSamples.standing(AssaultSamples.rival_of(game), HARPOONIST) < 40)


func test_a_fallen_attacker_cancels_the_attack() -> void:
	var game := _announced(false)
	AssaultSamples.rival_of(game).saved_fallen = true

	_end_turn(game)

	assert_true(_assaults(game.human_player()).is_empty())
	assert_true(game.human_player().raid_state.attacks.is_empty())


func test_the_attack_goes_with_the_units_the_attacker_still_has() -> void:
	var game := _announced()

	AssaultSamples.station(AssaultSamples.rival_of(game), {HARPOONIST: 10})
	_end_turn(game)

	assert_eq(_assaults(AssaultSamples.rival_of(game))[0].units, {HARPOONIST: 10})


func test_an_attacker_with_nothing_left_cancels_the_attack() -> void:
	var game := _announced(false)

	AssaultSamples.station(AssaultSamples.rival_of(game), {})
	_end_turn(game)

	assert_true(_assaults(game.human_player()).is_empty())
	assert_true(game.human_player().raid_state.attacks.is_empty())

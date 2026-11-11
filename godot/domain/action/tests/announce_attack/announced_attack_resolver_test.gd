extends TestCase
## Not in the Dart files: what AnnouncedAttackResolver, the step of the
## end of the turn that fights the attacks announced, does beyond the tests
## of announced_attack_resolve_test.dart and announced_attack_report_test.dart
## (the game of AssaultSamples.announce_game at turn 12): the noise of the
## attacker, an attacker gone, an attack due later, the dice announced.

const HARPOONIST := UnitType.Value.HARPOONIST


func _announced() -> Game:
	var game := AssaultSamples.announce_game()
	AssaultSamples.station(game.human_player(), {})
	AssaultSamples.announce().execute(game, AssaultSamples.rival_of(game))
	return game


func _assaults(p: Player) -> Array[BaseAssaultEntry]:
	var found: Array[BaseAssaultEntry] = []
	for e: HistoryEntry in p.history_entries:
		if e is BaseAssaultEntry:
			found.append(e)
	return found


func test_the_attacker_makes_its_noise_and_resolve_gives_the_results() -> void:
	var game := _announced()
	var results := AnnouncedAttackResolver.resolve(game)
	assert_eq(results.size(), 1)
	assert_true(results[0].victory)
	assert_true(AssaultSamples.rival_of(game).raid_state.noise > 0)


func test_an_attacker_gone_from_the_game_cancels_the_attack() -> void:
	var gone := _announced()
	gone.players.erase(AssaultSamples.rival_of(gone).id)
	assert_eq(AnnouncedAttackResolver.resolve(gone), [])
	assert_eq(_assaults(gone.human_player()), [])
	assert_eq(gone.human_player().raid_state.attacks.size(), 0)


func test_an_attack_due_later_waits() -> void:
	var game := _announced()
	var attack: AnnouncedAttack = game.human_player().raid_state.attacks[0]
	attack.arrival_turn = 13
	assert_eq(AnnouncedAttackResolver.resolve(game), [])
	assert_eq(game.human_player().raid_state.attacks, [attack])
	game.turn = 13
	assert_eq(AnnouncedAttackResolver.resolve(game).size(), 1)


## The fight of `game`'s rival on its human, the casualties of both sides.
func _casualties(game: Game) -> String:
	var mine := _assaults(AssaultSamples.rival_of(game))[0]
	var theirs := _assaults(game.human_player())[0]
	return "%d %s %s %s %s" % [mine.fight_result.turn_count, mine.dead, mine.wounded, theirs.dead, theirs.wounded]


func test_the_attack_is_fought_with_the_dice_it_announced() -> void:
	var defenders: Dictionary[UnitType.Value, int] = {UnitType.Value.GUARDIAN: 12, HARPOONIST: 12}
	var announced := _announced()
	AssaultSamples.station(announced.human_player(), defenders)
	var attack: AnnouncedAttack = announced.human_player().raid_state.attacks[0]
	AnnouncedAttackResolver.resolve(announced)
	var direct := AssaultSamples.announce_game()
	AssaultSamples.station(direct.human_player(), defenders)
	var rival := AssaultSamples.rival_of(direct)
	var action := AttackBaseAction.new(direct.human_player().id, attack.units, DartRandom.new(attack.fight_seed))
	var result := action.execute(direct, rival)
	rival.add_history_entry(action.make_history_entry(direct, rival, result, direct.turn))
	assert_eq(_casualties(announced), _casualties(direct))

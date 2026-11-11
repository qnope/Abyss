extends TestCase
## Not in the Dart files: announced_attack_resolve_test.dart and
## announced_attack_report_test.dart fight the attacks announced through
## the end of a turn (`turn`); these call AnnouncedAttackResolver, the step
## of the end of the turn that fights them, on the game of
## AssaultSamples.announce_game at turn 12.

const HARPOONIST := UnitType.Value.HARPOONIST
const CULT := FactionPersonality.Value.ANGLER_CULT


func _announced(rival_id := "rival-1") -> Game:
	var game := AssaultSamples.announce_game(12, rival_id)
	AssaultSamples.station(game.human_player(), {})
	AssaultSamples.announce().execute(game, AssaultSamples.rival_of(game))
	return game


func _assaults(p: Player) -> Array[BaseAssaultEntry]:
	var found: Array[BaseAssaultEntry] = []
	for e: HistoryEntry in p.history_entries:
		if e is BaseAssaultEntry:
			found.append(e)
	return found


func test_the_attack_is_fought_on_the_turn_it_is_decided() -> void:
	var game := _announced()
	assert_eq(AnnouncedAttackResolver.resolve(game).size(), 1)
	var entries := _assaults(game.human_player())
	assert_eq([entries.size(), entries[0].turn], [1, 12])
	assert_eq(game.human_player().raid_state.attacks.size(), 0)


func test_the_units_standing_on_the_base_defend_and_a_won_attack_razes_it() -> void:
	var game := _announced()
	var hq := game.human_player().buildings[BuildingType.Value.HEADQUARTERS].level
	var fought := AnnouncedAttackResolver.fight(game)
	assert_true(fought[0].result.victory)
	assert_eq(game.human_player().buildings[BuildingType.Value.HEADQUARTERS].level, hq - 1)
	var rival := AssaultSamples.rival_of(game)
	var mine := _assaults(rival)
	assert_eq([mine.size(), mine[0].defending], [1, false])
	assert_true(rival.raid_state.noise > 0)
	assert_eq(fought[0].report.outcome(), AttackOutcome.Value.PILLAGED)
	assert_null(fought[0].report.personality)
	var walled := _announced()
	AssaultSamples.station(walled.human_player(), AssaultSamples.WALL)
	var held := AnnouncedAttackResolver.fight(walled)[0]
	assert_eq([held.report.entry.victory, held.report.outcome()], [false, AttackOutcome.Value.REPELLED])
	assert_eq(_assaults(walled.human_player())[0].units, AssaultSamples.WALL)


func test_a_faction_is_reported_with_its_personality() -> void:
	var game := _announced(Faction.new(CULT).id())
	game.saved_factions.assign([CULT])
	var report := AnnouncedAttackResolver.fight(game)[0].report
	assert_eq([report.attacker_id, report.personality], [AssaultSamples.rival_of(game).id, CULT])
	assert_true(report.entry.defending)


func test_the_attack_goes_with_the_units_the_attacker_still_has() -> void:
	var game := _announced()
	var rival := AssaultSamples.rival_of(game)
	AssaultSamples.station(rival, {HARPOONIST: 10})
	AnnouncedAttackResolver.resolve(game)
	assert_eq(_assaults(rival)[0].units, {HARPOONIST: 10})


func test_a_fallen_attacker_or_one_with_nothing_left_cancels_the_attack() -> void:
	var fallen := _announced()
	AssaultSamples.rival_of(fallen).saved_fallen = true
	var empty := _announced()
	AssaultSamples.station(AssaultSamples.rival_of(empty), {})
	var gone := _announced()
	gone.players.erase(AssaultSamples.rival_of(gone).id)
	for game: Game in [fallen, empty, gone]:
		assert_eq(AnnouncedAttackResolver.resolve(game), [])
		assert_eq(_assaults(game.human_player()), [])
		assert_eq(game.human_player().raid_state.attacks.size(), 0)


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

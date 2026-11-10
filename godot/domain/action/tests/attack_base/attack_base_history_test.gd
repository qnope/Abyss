extends TestCase
## test/domain/action/attack_base/attack_base_history_test.dart: the history
## entries both players keep of an attack, and its noise.

const CORAL := ResourceType.Value.CORAL
const HORDE := AssaultSamples.HORDE


func _assaults(player: Player) -> Array[BaseAssaultEntry]:
	var found: Array[BaseAssaultEntry] = []
	for e: HistoryEntry in player.history_entries:
		if e is BaseAssaultEntry:
			found.append(e as BaseAssaultEntry)
	return found


func _single(player: Player) -> BaseAssaultEntry:
	var found := _assaults(player)
	assert_eq(found.size(), 1)
	return found[0]


func test_both_players_keep_a_history_entry_of_the_attack() -> void:
	var game := AssaultSamples.assault_game()
	var human := game.human_player()
	var rival := AssaultSamples.rival_of(game)
	AssaultSamples.station(human, HORDE)
	rival.resources[CORAL].amount = 1000
	ActionExecutor.new().execute(AssaultSamples.strike(game, HORDE), game, human)
	var mine := _single(human)
	var theirs := _single(rival)
	assert_false(mine.defending)
	assert_true(theirs.defending)
	assert_eq(mine.opponent_name, "rival")
	assert_eq(theirs.opponent_name, "human")
	assert_true(mine.victory)
	assert_true(theirs.victory)
	assert_eq(mine.turn, 12)
	assert_eq(theirs.turn, 12)
	assert_eq(mine.headquarters_after, 4)
	assert_eq(mine.loot[CORAL], 300)
	assert_eq(theirs.pillaged[CORAL], 300)


func test_a_lost_attack_is_recorded_for_both_players_too() -> void:
	var game := AssaultSamples.assault_game()
	var human := game.human_player()
	var rival := AssaultSamples.rival_of(game)
	AssaultSamples.station(human, {UnitType.Value.SCOUT: 2})
	AssaultSamples.station(rival, AssaultSamples.WALL)
	AssaultSamples.set_level(rival, BuildingType.Value.CORAL_CITADEL, 2)
	ActionExecutor.new().execute(AssaultSamples.strike(game, {UnitType.Value.SCOUT: 2}), game, human)
	assert_false(_single(human).victory)
	assert_false(_single(rival).victory)


func test_the_attack_never_counts_as_a_lost_raid() -> void:
	var game := AssaultSamples.assault_game()
	var human := game.human_player()
	AssaultSamples.station(human, HORDE)
	AssaultSamples.station(AssaultSamples.rival_of(game), {})
	ActionExecutor.new().execute(AssaultSamples.strike(game, HORDE), game, human)
	for p: Player in [human, AssaultSamples.rival_of(game)]:
		assert_eq(p.raid_state.lost_in_a_row, 0)
		assert_eq(p.raid_state.raids_lost, 0)
		assert_eq(p.raid_state.raids_repelled, 0)


func test_attacking_makes_the_noise_of_a_fight() -> void:
	var game := AssaultSamples.assault_game()
	var human := game.human_player()
	AssaultSamples.station(human, HORDE)
	var before := human.raid_state.noise
	ActionExecutor.new().execute(AssaultSamples.strike(game, HORDE), game, human)
	assert_eq(human.raid_state.noise - before, NoiseRules.PER_FIGHT)
	assert_eq(AssaultSamples.rival_of(game).raid_state.noise, 0)


## Not in the Dart file: its type and words, and no entry for a refusal.
func test_names_itself_and_writes_nothing_for_a_refusal() -> void:
	var game := AssaultSamples.assault_game()
	var action := AssaultSamples.strike(game, HORDE)
	assert_eq(action.type(), ActionType.Value.ATTACK_BASE)
	assert_eq(action.description(), "Attaque base rival-1")
	var refused := action.execute(game, game.human_player())
	assert_eq(refused.reason, ActionFailure.Value.NOT_ENOUGH_UNITS)
	assert_null(action.make_history_entry(game, game.human_player(), refused, 12))
	assert_null(action.make_history_entry(game, game.human_player(), ActionResult.success(), 12))

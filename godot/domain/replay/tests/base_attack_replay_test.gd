extends TestCase
## test/domain/replay/base_attack_replay_test.dart.

const RIVAL_ID := LiveGames.RIVAL_ID


func test_a_game_with_an_attack_replays_to_the_same_state_dice_included() -> void:
	var live := _play_with_attack(16, 10)
	var rival: Player = live.players[RIVAL_ID]

	assert_eq(_assaults(live.human_player()).size(), 1)
	var json := ReplayExport.to_json(live)
	var seeded := false
	var turns: Dictionary = json["turns"]
	for planned: Array in turns.values():
		for action: Dictionary in planned:
			seeded = seeded or (action["do"] == "attackPlayer" and typeof(action.get("seed")) == TYPE_INT)
	assert_true(seeded)

	var replayed := LiveGames.replay_on(json)

	assert_eq(LiveGames.both(replayed), LiveGames.both(live))
	var damage := replayed.human_player().buildings[BuildingType.Value.HEADQUARTERS].level
	assert_eq(damage, live.human_player().buildings[BuildingType.Value.HEADQUARTERS].level)
	assert_eq(_assaults(replayed.players[RIVAL_ID]).size(), _assaults(rival).size())


## `_playWithAttack`: two players play `turns` turns; the rival sends all
## its fighters against the human's base from turn `attack_from` on, once.
static func _play_with_attack(turns: int, attack_from: int) -> Game:
	var game := GameSamples.two_players(3, RIVAL_ID)
	var human := game.human_player()
	var rival: Player = game.players[RIVAL_ID]
	var seeds := DartRandom.new(5, false)
	var executor := ActionExecutor.new()
	var attacked := false
	for t: int in range(1, turns + 1):
		BalancedStrategy.new().play_turn(FactionGames.LiveTurn.new(game, human, seeds))
		var turn := FactionGames.LiveTurn.new(game, rival, seeds)
		BalancedStrategy.new().play_turn(turn)
		if not attacked and t >= attack_from:
			var army: Dictionary[UnitType.Value, int] = {}
			var on_level := rival.units_on_level(1)
			for type: UnitType.Value in on_level:
				if on_level[type].count > 0:
					army[type] = on_level[type].count
			attacked = not army.is_empty() and AssaultMoves.attack_base(turn, human.id, army)
		executor.execute(EndTurnAction.new(DartRandom.new(seeds.next_int(1 << 30))), game, human)
	return game


static func _assaults(player: Player) -> Array[HistoryEntry]:
	return player.history_entries.filter(func(e: HistoryEntry) -> bool: return e is BaseAssaultEntry)

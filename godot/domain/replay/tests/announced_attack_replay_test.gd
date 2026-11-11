extends TestCase
## test/domain/replay/announced_attack_replay_test.dart.

const RIVAL_ID := LiveGames.RIVAL_ID


func test_an_announced_attack_replays_to_the_same_game_without_any_brain() -> void:
	var live := _play_with_announcement(18, 10)

	assert_eq(_assaults(live.human_player()).size(), 1, "decided at 10 or later, fought the same turn")
	var json := ReplayExport.to_json(live)
	var journalled: Array[Dictionary] = []
	var turns: Dictionary = json["turns"]
	for planned: Array in turns.values():
		for action: Dictionary in planned:
			if action["do"] == "announceAttack":
				journalled.append(action)
	assert_eq(journalled.size(), 1)
	assert_eq(typeof(journalled[0]["seed"]), TYPE_INT)
	assert_eq(journalled[0]["player"], RIVAL_ID)
	assert_eq(json["exact"], true)

	var replayed := LiveGames.replay_on(json)

	assert_eq(LiveGames.both(replayed), LiveGames.both(live))
	assert_eq(_assaults(replayed.human_player()).size(), 1)


## `_playWithAnnouncement`: two players play `turns` turns; from
## `announce_from` on the rival announces, once, an attack with all its
## fighters on the human.
static func _play_with_announcement(turns: int, announce_from: int) -> Game:
	var game := GameSamples.two_players(3, RIVAL_ID)
	var human := game.human_player()
	var rival: Player = game.players[RIVAL_ID]
	var seeds := DartRandom.new(5, false)
	var executor := ActionExecutor.new()
	var announced := false
	for t: int in range(1, turns + 1):
		BalancedStrategy.new().play_turn(FactionGames.LiveTurn.new(game, human, seeds))
		var turn := FactionGames.LiveTurn.new(game, rival, seeds)
		BalancedStrategy.new().play_turn(turn)
		if not announced and t >= announce_from:
			var army: Dictionary[UnitType.Value, int] = {}
			var on_level := rival.units_on_level(1)
			for type: UnitType.Value in on_level:
				if on_level[type].count > 0 and type != UnitType.Value.SCOUT:
					army[type] = on_level[type].count
			announced = not army.is_empty() and AssaultMoves.announce_attack(turn, army)
		executor.execute(EndTurnAction.new(DartRandom.new(seeds.next_int(1 << 30))), game, human)
	return game


static func _assaults(player: Player) -> Array[HistoryEntry]:
	return player.history_entries.filter(func(e: HistoryEntry) -> bool: return e is BaseAssaultEntry)

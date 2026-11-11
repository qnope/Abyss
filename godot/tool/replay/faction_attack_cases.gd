class_name FactionAttackCases
extends RefCounted
## test/domain/faction/faction_attack_play_test.dart, too long for the unit
## tests: games of 100 turns against three factions. Its four tests of
## `playIdleFactionGame(3, 100)` read the one game it plays every time.


static func run() -> PackedStringArray:
	var checks := CaseChecks.new()
	# Three factions play 100 turns, attacks included, without error.
	var played := FactionGames.play(3, 100)
	checks.expect(played.turn > 60, "the balanced game stopped on turn %d" % played.turn)
	checks.expect(played.replay.exact, "the journal of the balanced game is not exact")

	var game := FactionGames.play_idle(3, 100)
	var announced := _announcements(game)
	# A faction attacks an idle human the very turn it decides to.
	var turns := announced.map(func(a: Array) -> int: return a[0])
	var fights := _assaults(game.human_player()).filter(func(e: BaseAssaultEntry) -> bool: return e.defending)
	checks.expect(not announced.is_empty(), "no attack announced")
	checks.expect(not fights.is_empty(), "no attack fought")
	for fight: BaseAssaultEntry in fights:
		checks.expect(turns.has(fight.turn), "fought on turn %d, not the turn it was decided" % fight.turn)
	# The army that fights is the one decided, less what it lost.
	var checked := 0
	for a: Array in announced:
		var action: Dictionary = a[1]
		var units: Dictionary = action["units"]
		for fight: BaseAssaultEntry in _assaults(game.players[action["player"]]):
			if fight.defending or fight.turn != a[0]:
				continue
			checks.expect(not fight.units.is_empty(), "an attack of turn %d without units" % fight.turn)
			for type: UnitType.Value in fight.units:
				var name := DartEnum.name_of(UnitType.Value, type)
				var decided: int = units.get(name, 0)
				checks.expect(fight.units[type] <= decided, "turn %d: more %s than decided" % [fight.turn, name])
			checked += 1
	checks.expect(checked > 0, "no attacker's fight checked")
	_replays_without_any_brain(game, checks)
	# An attack never counts as a raid lost by the human.
	var human := game.human_player()
	var won := _assaults(human).filter(func(e: BaseAssaultEntry) -> bool: return e.victory)
	var raids_lost := human.history_entries.filter(func(e: HistoryEntry) -> bool: return e is RaidEntry and not (e as RaidEntry).victory)
	checks.expect(not won.is_empty(), "the human never held an attack")
	checks.expect(human.raid_state.raids_lost == raids_lost.size(), "%d raids lost, %d in the history" % [human.raid_state.raids_lost, raids_lost.size()])
	checks.expect(game.status == GameStatus.Value.DEFEAT, "the idle human was not defeated")
	return checks.failures


## A game with announced attacks replays without any brain.
static func _replays_without_any_brain(live: Game, checks: CaseChecks) -> void:
	var capture := GameCapture.new()
	var script := ScenarioParser.parse(JSON.stringify(ReplayExport.to_json(live), "", false))
	ScriptRunner.new(500, Difficulty.Value.NORMAL, null, capture).run(script, 1)
	var replayed := capture.game()
	checks.expect(replayed.turn == live.turn and replayed.status == live.status, "the replay stopped on turn %d" % replayed.turn)
	checks.expect(_everyone(replayed) == _everyone(live), "the replay ends in another state")
	checks.expect(JSON.stringify(replayed.replay.actions, "", false) == JSON.stringify(live.replay.actions, "", false), "the replay journals other actions")
	checks.expect(_assaults(replayed.human_player()).size() == _assaults(live.human_player()).size(), "the replay fights other attacks")


## `everyone`: the snapshots of the human and of every faction.
static func _everyone(game: Game) -> String:
	var found := {"human": LiveGames.snapshot_of(game)}
	for faction: Faction in game.factions():
		found[faction.id()] = LiveGames.snapshot_of(game, game.players[faction.id()])
	return JSON.stringify(found, "", false)


## `announcements`: the turn of each attack the journal holds, and its move.
static func _announcements(game: Game) -> Array[Array]:
	var turns := game.replay.actions.keys()
	turns.sort()
	var found: Array[Array] = []
	for turn: int in turns:
		for action: Dictionary in game.replay.actions_of(turn):
			if action["do"] == "announceAttack":
				found.append([turn, action])
	return found


static func _assaults(player: Player) -> Array[BaseAssaultEntry]:
	var found: Array[BaseAssaultEntry] = []
	for entry: HistoryEntry in player.history_entries:
		if entry is BaseAssaultEntry:
			found.append(entry)
	return found

class_name LiveGames
extends RefCounted
## The twin of test/domain/replay/live_game_helper.dart and
## two_player_replay_helper.dart: games played as in the game screen, every
## die a new `SeededRandom` (FactionGames.LiveTurn), and what a replay must
## reproduce of them. `SpyExecutor`, `replayOn` and `Fallback` serve the
## runners of `script`, not ported.

const RIVAL_ID := "rival-1"


## `playLiveGame`: plays `script` the way a player would in the app, with
## unpredictable (but here reproducible) seeds, for `turns` turns or until
## it is over.
static func play_live_game(script: GameScript, turns: int, seed_ := 1) -> Game:
	var seeds := DartRandom.new(seed_, false)
	var game := GameFactory.new_single_player("Nemo", seeds.next_int(0x7FFFFFFF))
	var executor := ActionExecutor.new()
	while game.status == GameStatus.Value.PLAYING and game.turn <= turns:
		var turn := FactionGames.LiveTurn.new(game, game.human_player(), seeds)
		script.play_turn(turn)
		if turn.is_over() or game.turn == turns:
			break
		executor.execute(EndTurnAction.new(DartRandom.new(seeds.next_int(1 << 30))), game, game.human_player())
	return game


## `playTwo`: a game where the human (balanced) and the rival (economy) play
## `turns` turns, one after the other, with unpredictable seeds.
static func play_two(turns: int) -> Game:
	var game := GameSamples.two_players(3, RIVAL_ID)
	var seeds := DartRandom.new(5, false)
	var executor := ActionExecutor.new()
	for _t: int in turns:
		BalancedStrategy.new().play_turn(FactionGames.LiveTurn.new(game, game.human_player(), seeds))
		EconomyStrategy.new().play_turn(FactionGames.LiveTurn.new(game, game.players[RIVAL_ID], seeds))
		executor.execute(EndTurnAction.new(DartRandom.new(seeds.next_int(1 << 30))), game, game.human_player())
	return game


## `both`: the snapshots of the human and of the rival.
static func both(game: Game) -> Dictionary:
	return {"human": snapshot_of(game), "rival": snapshot_of(game, game.players[RIVAL_ID])}


## `snapshotOf`: what a replay must reproduce of `game`, for `of` (the
## human when null). The pending attacks are written as texts of their own,
## not Dart's: only two Godot games are compared.
static func snapshot_of(game: Game, of: Player = null) -> Dictionary:
	var player := of if of != null else game.human_player()
	var resources := {}
	for type: ResourceType.Value in player.resources:
		resources[DartEnum.name_of(ResourceType.Value, type)] = player.resources[type].amount
	var buildings := {}
	for type: BuildingType.Value in player.buildings:
		buildings[DartEnum.name_of(BuildingType.Value, type)] = player.buildings[type].level
	var units := {}
	for level: int in player.units_per_level:
		var counts := {}
		var on_level := player.units_on_level(level)
		for type: UnitType.Value in on_level:
			counts[DartEnum.name_of(UnitType.Value, type)] = on_level[type].count
		units[str(level)] = counts
	var attacks: Array[String] = []
	for a: AnnouncedAttack in player.raid_state.attacks:
		attacks.append("%s %d %d %s" % [a.attacker_id, a.arrival_turn, a.fight_seed, a.units])
	var history: Array[String] = []
	for e: HistoryEntry in player.history_entries:
		history.append("%d %s" % [e.turn, DartEnum.name_of(HistoryEntryCategory.Value, e.category)])
	return {
		"turn": game.turn,
		"status": DartEnum.name_of(GameStatus.Value, game.status),
		"levels": game.levels.keys(),
		"resources": resources,
		"buildings": buildings,
		"units": units,
		"noise": player.raid_state.total_noise,
		"attacks": attacks,
		"history": history,
	}

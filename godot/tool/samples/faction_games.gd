class_name FactionGames
extends RefCounted
## The twin of test/helpers/faction_game.dart: games against the factions
## played turn after turn through EndTurnAction, the human balanced
## (`play`), and the growth of a player. `LiveTurn` is
## the twin of the one of test/domain/replay/two_player_replay_helper.dart.


## A turn whose every die is a new `SeededRandom` drawn from the game's
## seeds, as the game screen journals them.
class LiveTurn:
	extends ScriptTurn

	var _seeds: DartRandom

	func _init(game_: Game, player_: Player, seeds: DartRandom) -> void:
		super(game_, seeds, [], player_)
		_seeds = seeds

	func random() -> DartRandom:
		return DartRandom.new(_seeds.next_int(0x7FFFFFFF))


## `playFactionGame`: a game against `factions` factions where the human
## plays the balanced strategy until `turns`, with journalled (seeded) dice;
## the factions play inside the end of each turn.
static func play(factions: int, turns: int, seed_ := 5, difficulty := Difficulty.Value.NORMAL) -> Game:
	var seeds := DartRandom.new(seed_, false)
	var game := GameFactory.new_game("Nemo", seeds.next_int(0x7FFFFFFF), difficulty, false, factions)
	var executor := ActionExecutor.new()
	while game.status == GameStatus.Value.PLAYING and game.turn < turns:
		BalancedStrategy.new().play_turn(LiveTurn.new(game, game.human_player(), seeds))
		executor.execute(EndTurnAction.new(DartRandom.new(seeds.next_int(1 << 30))), game, game.human_player())
	return game


## `growthOf`: the levels of the buildings and the units of `player`.
static func growth_of(player: Player) -> int:
	var total := 0
	for b: Building in player.buildings.values():
		total += b.level
	for level: int in player.units_per_level:
		for u: Unit in player.units_on_level(level).values():
			total += u.count
	return total

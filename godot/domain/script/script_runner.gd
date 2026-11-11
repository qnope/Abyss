class_name ScriptRunner
extends RefCounted
## lib/domain/script/script_runner.dart: plays a whole game headless with a
## GameScript.
##
## One seed drives the map, every fight and every raid, so the same script
## and seed always replay the same game.

## The game stops after this many turns if it is not over before; a replay
## stops on its own last turn instead.
var max_turns: int
## Difficulty of the games, unless the script pins its own.
var difficulty: Difficulty.Value
## Id of the human player of the games (a String); null draws one per
## game, as the game screen does. A faction breaks a tie between two bases
## by their ids: a reference game pins this one to play the same again.
var human_id: Variant

var _executor: ActionExecutor


func _init(
	max_turns_ := 60, difficulty_ := Difficulty.Value.NORMAL, human_id_: Variant = null,
	executor: ActionExecutor = null,
) -> void:
	max_turns = max_turns_
	difficulty = difficulty_
	human_id = human_id_
	_executor = executor if executor != null else ActionExecutor.new()


func run(script: GameScript, seed_: int) -> ScriptRunReport:
	var random := DartRandom.new(seed_, false)
	var drawn_seed := random.next_int(0x7FFFFFFF)
	var pinned: Difficulty.Value = script.difficulty() if script.difficulty() != null else difficulty
	var game := GameFactory.new_game(
		script.player_name(), script.map_seed() if script.map_seed() != null else drawn_seed,
		pinned, false, 0, script.factions(), human_id,
	)
	CheatCodes.apply(game.human_player())
	return run_on(game, script, random, seed_)


## Plays `game` with `script` for `player_id` (a String; the human when
## null). The human player still ends the turns: they belong to the game.
func run_on(game: Game, script: GameScript, random: DartRandom, seed_: int, player_id: Variant = null) -> ScriptRunReport:
	var player := game.human_player()
	if player_id != null and game.players.has(player_id):
		player = game.players[player_id]
	var log: Array[ScriptLogEntry] = []
	var milestones := ScriptMilestones.new()
	var turn_limit: int = script.last_turn() if script.last_turn() != null else max_turns
	while game.status == GameStatus.Value.PLAYING and game.turn <= turn_limit:
		var turn := ScriptTurn.new(game, random, log, player, _executor)
		script.play_turn(turn)
		milestones.observe(game, game.turn, player.id)
		if game.turn == script.last_turn():
			break
		if turn.is_over() and game.status != GameStatus.Value.DEFEAT:
			break
		# A faction tames the volcano while the turn ends, and the turn ends
		# all the same. A replay plays that move before ending the turn: it
		# ends the turn too when the journal holds its seed.
		var recorded := script.end_turn_random(game.turn)
		if turn.is_over() and recorded == null:
			break
		var end := _executor.execute(
			EndTurnAction.new(recorded if recorded != null else random, script.factions_play()),
			game, game.human_player(),
		)
		var turn_result: TurnResult = (end as EndTurnActionResult).turn_result if end is EndTurnActionResult else null
		if turn_result != null and player.id == game.human_player_id:
			if turn_result.raid != null:
				milestones.raids.append(ScriptRaid.of(turn_result.raid))
			milestones.observe_wave(turn_result.volcano)
			milestones.observe_leviathan(turn_result.leviathan)
	return ScriptRunReport.of(game, script.name(), seed_, log, milestones, player.id)

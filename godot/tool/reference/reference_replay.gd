class_name ReferenceReplay
extends RefCounted
## Not in the Dart files: the replay of a reference game
## (reference/README.md, "Replaying it"), as ScriptRunner.runOn plays the
## TimelineScript of its journal with the factions' brains off, recording
## as ReferenceRecorder does the digests of every section as turn 1 starts
## and after each end of turn, and when it stops.
##
## A move of the journal is decoded by `decode`, a Callable taking the move
## (a Dictionary) and the dice of the turn (a DartRandom) and giving its
## Action, which rolls with `SeededRandom(seed)` when the move has a seed:
## the codec of the actions plugs in there. A journal without moves
## (`idle-normal`) needs none.

var game: Game
var turns: Array[ReplayComparison.Turn] = []
var final_digests: PackedStringArray


func _init(committed: CommittedGame, decode := Callable()) -> void:
	game = committed.starting_game()
	var journal := committed.journal()
	var moves: Dictionary = journal["turns"]
	var seeds: Dictionary = journal["endTurnSeeds"]
	var last: float = journal["lastTurn"]
	var random := DartRandom.new(0, false)
	var log: Array[ScriptLogEntry] = []
	var executor := ActionExecutor.new()
	_record()
	while game.status == GameStatus.Value.PLAYING and game.turn <= int(last):
		var turn := ScriptTurn.new(game, random, log, null, executor)
		for move: Dictionary in moves.get(str(game.turn), []):
			var actor := turn if not move.has("player") else turn.as_player(game.players[move["player"]])
			var action: Action = decode.call(move, turn.random())
			actor.perform(action)
		if game.turn == int(last) or (turn.is_over() and game.status != GameStatus.Value.DEFEAT):
			break
		var recorded: Variant = seeds.get(str(game.turn))
		if turn.is_over() and recorded == null:
			break
		var dice := random
		if recorded != null:
			var seed_: float = recorded
			dice = DartRandom.new(int(seed_))
		if executor.execute(EndTurnAction.new(dice, false), game, game.human_player()).is_success:
			_record()
	final_digests = GameSnapshot.digests(game, Sha256Hex.of)


func _record() -> void:
	turns.append(ReplayComparison.Turn.new(game.turn, GameSnapshot.digests(game, Sha256Hex.of)))

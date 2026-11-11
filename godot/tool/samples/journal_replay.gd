class_name JournalReplay
extends RefCounted
## Replays the journal of a game of `reference/games/` as Dart's
## `ReferenceExporter` does (reference/README.md, "Replaying it"): the
## `TimelineScript` that `ScenarioParser` reads from it, played by
## `ScriptRunner.run` with the human id of the reference games. The runners
## of `script` are not ported: this plays their steps for a journal alone.

## `ReferenceExporter.humanId`.
const HUMAN_ID := "00000000-0000-4000-8000-000000000000"

var game: Game
## The actions of the journal that did not succeed, as
## "turn <n> #<i> <do>: <reason>".
var refused: Array[String] = []
## The actions left unplayed in a turn a faction won (`GAME_OVER`).
var unplayed := 0
## The number of actions played, and of turns ended.
var played := 0
var ends := 0

var _journal: Dictionary
var _executor := ActionExecutor.new()


## `journal` and `source` as a reference file holds them, read by Godot's
## JSON (their whole numbers may be floats).
func _init(journal: Dictionary, source: Dictionary) -> void:
	_journal = ReplayJournal.whole_numbers(journal)
	var from: Dictionary = ReplayJournal.whole_numbers(source)
	var seed_: int = from["seed"]
	var random := DartRandom.new(seed_, false)
	var drawn := random.next_int(0x7FFFFFFF)
	var personalities: Array[FactionPersonality.Value] = []
	for name: String in _journal.get("factions", []):
		personalities.append(DartEnum.by_name(FactionPersonality.Value, name))
	var player_name: String = _journal.get("player", _journal.get("name", "scenario"))
	var map_seed: int = _journal.get("mapSeed", drawn)
	var difficulty_name: String = _journal.get("difficulty", from["difficulty"])
	var difficulty: Difficulty.Value = DartEnum.by_name(Difficulty.Value, difficulty_name)
	game = GameFactory.new_game(player_name, map_seed, difficulty, false, 0, personalities, HUMAN_ID)
	CheatCodes.apply(game.human_player())
	var turn_limit: int = _journal.get("lastTurn", from["turns"])
	_run(random, turn_limit)


## `ScriptRunner.runOn` with a `TimelineScript`, whose factions never play.
func _run(random: DartRandom, turn_limit: int) -> void:
	var player := game.human_player()
	var log: Array[ScriptLogEntry] = []
	var last_turn: Variant = _journal.get("lastTurn")
	var seeds: Dictionary = _journal.get("endTurnSeeds", {})
	while game.status == GameStatus.Value.PLAYING and game.turn <= turn_limit:
		var turn := ScriptTurn.new(game, random, log, player, _executor)
		_play_turn(turn)
		if game.turn == last_turn:
			break
		if turn.is_over() and game.status != GameStatus.Value.DEFEAT:
			break
		var recorded: DartRandom = null
		if seeds.has(str(game.turn)):
			var end_seed: int = seeds[str(game.turn)]
			recorded = DartRandom.new(end_seed)
		if turn.is_over() and recorded == null:
			break
		_executor.execute(EndTurnAction.new(recorded if recorded != null else random, false), game, game.human_player())
		ends += 1


## `TimelineScript.playTurn`: each action of the turn as its player, its
## spec given the turn's dice.
func _play_turn(turn: ScriptTurn) -> void:
	var turns: Dictionary = _journal.get("turns", {})
	var planned: Array = turns.get(str(turn.number()), [])
	for i: int in planned.size():
		var move: Dictionary = planned[i]
		var actor := turn
		if move.get("player") != null:
			var id: String = move["player"]
			actor = turn.as_player(game.players[id])
		var spec := ActionCodec.decode(move)
		var action: Action = spec.call(turn.random())
		var result := actor.perform(action)
		played += 1
		if result.reason == ActionFailure.Value.GAME_OVER:
			unplayed += 1
		elif not result.is_success:
			var reason: int = result.reason
			refused.append("turn %d #%d %s: %s" % [
				turn.number(), i, move["do"], DartEnum.name_of(ActionFailure.Value, reason)
			])


## The reference games of `reference/games/`, by file name, in name order.
static func reference_games() -> PackedStringArray:
	var files := DirAccess.get_files_at(games_dir())
	files.sort()
	return files


static func games_dir() -> String:
	return ReferenceFiles.repo_root().path_join("reference/games")


## The JSON of the reference game `file_name`.
static func read_game(file_name: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(games_dir().path_join(file_name)))

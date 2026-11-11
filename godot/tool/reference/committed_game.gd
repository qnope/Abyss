class_name CommittedGame
extends RefCounted
## test/domain/reference/committed_games.dart: a reference game of
## `reference/games/`, as its file tells it (reference/README.md, "A
## reference game"): its source, its result, the digests turn after turn,
## its coverage and its journal, and the game the replay starts from.
## ReferenceReplay replays it.

## The id the reference games are played with (ReferenceExporter.humanId).
const HUMAN_ID := "00000000-0000-4000-8000-000000000000"

## Name of the file, without `.json`.
var name: String
var json: Dictionary
## The length of its file, which grows with the time its replay takes.
var text_length: int


func _init(name_: String, text: String) -> void:
	name = name_
	json = JSON.parse_string(text)
	text_length = text.length()


## The games committed in `reference/games/`, by name.
static func all() -> Array[CommittedGame]:
	var folder := _folder()
	var files: Array[String] = []
	for file: String in DirAccess.get_files_at(folder):
		if file.ends_with(".json") and not file.ends_with(".dump.json") and not file.ends_with(".trace.json"):
			files.append(file)
	CanonicalKeys.sort(files)
	var games: Array[CommittedGame] = []
	for file: String in files:
		games.append(CommittedGame.new(file.trim_suffix(".json"), FileAccess.get_file_as_string(folder.path_join(file))))
	return games


## The game of `reference/games/` named `name_`, or null.
static func named(name_: String) -> CommittedGame:
	var path := _folder().path_join(name_ + ".json")
	return CommittedGame.new(name_, FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else null


static func _folder() -> String:
	return ReferenceFiles.repo_root().path_join("reference/games")


## `source` and `coverage` of the file, their whole numbers ints.
func source() -> Dictionary:
	return ReplayJournal.whole_numbers(_map("source"))


func coverage() -> Dictionary:
	return ReplayJournal.whole_numbers(_map("coverage"))


func status() -> String:
	return _map("result")["status"]


## The turn the game stopped on.
func turn() -> int:
	var number: float = _map("result")["turn"]
	return int(number)


func journal() -> Dictionary:
	return _map("journal")


## The names of the sections, in the order of every list of digests.
func sections() -> PackedStringArray:
	var names: Array = json["sections"]
	return PackedStringArray(names)


## The digests of `turns`, `=` written out: the state as each turn starts.
func turn_digests() -> Array[PackedStringArray]:
	var rows: Array[PackedStringArray] = []
	for entry: Dictionary in json["turns"]:
		var digests: Array = entry["digests"]
		rows.append(PackedStringArray(digests))
	return DigestRows.expand(rows)


## The turn of each entry of `turns`.
func turns() -> Array[int]:
	var found: Array[int] = []
	for entry: Dictionary in json["turns"]:
		var number: float = entry["turn"]
		found.append(int(number))
	return found


## The digests as each turn started, for ReplayComparison.same_turns.
func played_turns() -> Array[ReplayComparison.Turn]:
	var played: Array[ReplayComparison.Turn] = []
	var rows := turn_digests()
	for i: int in rows.size():
		played.append(ReplayComparison.Turn.new(turns()[i], rows[i]))
	return played


## The digests when the game stopped.
func final_digests() -> PackedStringArray:
	var digests: Array = json["final"]
	return PackedStringArray(digests)


## The game a replay starts from (reference/README.md, "Replaying it",
## step 1), as ScriptRunner.run creates it from the journal: its player,
## map seed, difficulty and factions, the human HUMAN_ID.
func starting_game() -> Game:
	var j := journal()
	var factions: Array[FactionPersonality.Value] = []
	for personality: String in j.get("factions", []):
		factions.append(DartEnum.by_name(FactionPersonality.Value, personality))
	var difficulty_name: String = j["difficulty"]
	var difficulty: Difficulty.Value = DartEnum.by_name(Difficulty.Value, difficulty_name)
	var player: String = j["player"]
	var map_seed: float = j["mapSeed"]
	var game := GameFactory.new_game(player, int(map_seed), difficulty, false, 0, factions, HUMAN_ID)
	CheatCodes.apply(game.human_player())
	return game


func _map(key: String) -> Dictionary:
	return json[key]

class_name GameRepository
extends RefCounted
## lib/data/game_repository.dart: the saved games, one file each in
## `folder` (data/README.md, "The saves folder"): `game-<n>.json`, `n`
## counting up from 1 as Hive numbers what it adds to a box, written whole
## or not at all (AtomicFile).
##
## A game it saved or loaded is kept with its file, so that saving it again
## replaces that file, as Hive saves a game already in its box.

const FOLDER := "user://saves"
const PREFIX := "game-"
const EXTENSION := ".json"

var folder: String
## Tells the time each save is stamped with: a Callable giving an int, a
## date as Game holds one.
var _now: Callable
var _files: Dictionary[Game, String] = {}


func _init(folder_ := FOLDER, now: Callable = Game.now) -> void:
	folder = folder_
	_now = now


## Stores `game`, stamping it as last played now; OK, or the error met,
## the previous save of the game then kept as it was.
func save(game: Game) -> Error:
	var stamp: int = _now.call()
	game.saved_last_played_at = stamp
	var file: String = _files.get(game, "")
	if file.is_empty():
		file = "%s%d%s" % [PREFIX, _last_number() + 1, EXTENSION]
	var error := AtomicFile.write(folder.path_join(file), SaveCodec.to_text(game))
	if error == OK:
		_files[game] = file
	return error


## Every saved game in the order first saved; a file it cannot read is
## skipped and named with why, never stopping the others.
func load_all() -> SavedGames:
	var found := SavedGames.new()
	for file: String in _saves():
		var text: Variant = AtomicFile.read(folder.path_join(file))
		var read := DecodedSave.refused("the file cannot be read")
		if text is String:
			var written: String = text
			read = SaveCodec.from_text(written)
		if read.is_read():
			found.games.append(read.game)
			_files[read.game] = file
		else:
			found.unreadable[file] = read.problem
	return found


## Removes `game` from the saves; does nothing if it was never stored.
func delete_game(game: Game) -> Error:
	if not _files.has(game):
		return OK
	var error := DirAccess.remove_absolute(folder.path_join(_files[game]))
	if error == OK:
		_files.erase(game)
	return error


## The names of the saves in the folder, by their number.
func _saves() -> Array[String]:
	var numbered: Dictionary[int, String] = {}
	for file: String in _files_in_folder():
		var number := _number_of(file)
		if number > 0:
			numbered[number] = file
	var numbers := numbered.keys()
	numbers.sort()
	var names: Array[String] = []
	for number: int in numbers:
		names.append(numbered[number])
	return names


func _last_number() -> int:
	var last := 0
	for file: String in _files_in_folder():
		last = maxi(last, _number_of(file))
	return last


## The files of the folder; none while it does not exist.
func _files_in_folder() -> PackedStringArray:
	return DirAccess.get_files_at(folder) if DirAccess.dir_exists_absolute(folder) else PackedStringArray()


## `n` of `game-<n>.json`, or 0 for any other file.
static func _number_of(file: String) -> int:
	if not file.begins_with(PREFIX) or not file.ends_with(EXTENSION):
		return 0
	var digits := file.trim_prefix(PREFIX).trim_suffix(EXTENSION)
	var number: Variant = DartInt.try_parse(digits)
	return number if number != null and number > 0 and str(number) == digits else 0

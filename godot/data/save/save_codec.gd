class_name SaveCodec
extends RefCounted
## A game to the JSON text of its save and back (data/README.md, "The save
## format"): `{"format":1,"game":{...}}`, every object keyed by the Dart
## names of its fields, in the order the game holds them.
##
## A text that is no JSON, that is cut short, that holds a field of the
## wrong type, or that comes from a newer format than FORMAT (or from an
## unknown one) is refused with its reason, never half read.

## The format this version writes, and the newest it reads.
const FORMAT := 1


static func to_text(game: Game) -> String:
	return JSON.stringify({"format": FORMAT, "game": GameCodec.game(game)}, "", false)


static func from_text(text: String) -> DecodedSave:
	var json := JSON.new()
	if json.parse(text) != OK:
		return DecodedSave.refused("not a save: %s, line %d" % [json.get_error_message(), json.get_error_line() + 1])
	var r := SaveReader.new()
	var root := r.object(json.data, "the save")
	var format := r.int_at(root, "format")
	if not r.ok():
		return DecodedSave.refused("not a save: " + r.problem)
	if format > FORMAT:
		return DecodedSave.refused("saved by a newer version (format %d, this one reads up to %d)" % [format, FORMAT])
	if format < 1:
		return DecodedSave.refused("unknown format %d" % format)
	var game := GameCodec.read_game(r, r.at(root, "game"))
	if r.ok() and not game.players.has(game.human_player_id):
		r.fail("the human player %s is not among the players" % game.human_player_id)
	if not r.ok():
		return DecodedSave.refused("unreadable save: " + r.problem)
	return DecodedSave.new(game)

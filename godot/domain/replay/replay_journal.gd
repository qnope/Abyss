class_name ReplayJournal
extends RefCounted
## lib/domain/replay/replay_journal.dart: every move of a game, in the order
## it was played, with the seeds that drove its dice: enough to replay the
## game turn for turn.
##
## Every player's moves share one list per turn, in the order played; a move
## of a player other than the human carries a `player` key. Unlike the
## history shown to the player, the journal is never trimmed.
##
## `record`, which notes an action that succeeded, needs the actions and
## their encoder: it comes with the action module.

var map_seed: int
var player_name: String
## JSON-encoded actions per turn: each value an `Array[String]`.
var actions: Dictionary[int, Array]
## Seed of the generator that drove each end of turn (raids).
var end_turn_seeds: Dictionary[int, int]
## Whether every die rolled so far came from a recorded seed.
var exact: bool


func _init(
	map_seed_: int,
	player_name_: String,
	actions_: Dictionary[int, Array] = {},
	end_turn_seeds_: Dictionary[int, int] = {},
	exact_ := true,
) -> void:
	map_seed = map_seed_
	player_name = player_name_
	actions = actions_
	end_turn_seeds = end_turn_seeds_
	exact = exact_


## Decoded actions of `turn`, oldest first, each key in the order it was
## written. Godot's JSON reads every number as a float: a whole one is
## turned back into the int Dart's `jsonDecode` gives, which is all the
## encoder writes.
func actions_of(turn: int) -> Array[Dictionary]:
	var decoded: Array[Dictionary] = []
	var texts: Array = actions.get(turn, [])
	for text: String in texts:
		var move: Dictionary = _whole_numbers(JSON.parse_string(text))
		decoded.append(move)
	return decoded


static func _whole_numbers(value: Variant) -> Variant:
	if value is float:
		var number: float = value
		return int(number) if number == floorf(number) else number
	if value is Array:
		var items: Array = value
		return items.map(_whole_numbers)
	if value is Dictionary:
		var entries: Dictionary = value
		var converted := {}
		for key: Variant in entries:
			converted[key] = _whole_numbers(entries[key])
		return converted
	return value

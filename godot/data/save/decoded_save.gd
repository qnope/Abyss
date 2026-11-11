class_name DecodedSave
extends RefCounted
## What SaveCodec read from a save: the game, or why it was refused.

## Null when the save was refused.
var game: Game
## Why the save was refused; empty when it was read.
var problem: String


func _init(game_: Game, problem_ := "") -> void:
	game = game_
	problem = problem_


static func refused(problem_: String) -> DecodedSave:
	return DecodedSave.new(null, problem_)


func is_read() -> bool:
	return game != null

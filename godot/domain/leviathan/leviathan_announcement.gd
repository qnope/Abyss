class_name LeviathanAnnouncement
extends RefCounted
## lib/domain/leviathan/leviathan_announcement.dart: the guardians announced
## against the human's Faille: they strike at the end of `turn`.

## Code of the Faille, as TransitionBaseName reads it.
var post_name: String
## Level of the map the Faille stands on, and its cell there.
var level: int
var at: GridPosition
## The turn at the end of which they strike.
var turn: int


func _init(post_name_: String, level_: int, at_: GridPosition, turn_: int) -> void:
	post_name = post_name_
	level = level_
	at = at_
	turn = turn_


## The attacking force, by type key.
func force() -> Dictionary[String, int]:
	return LeviathanForce.COUNTS


## The level whose units defend the Faille.
func defending_level() -> int:
	return level + 1

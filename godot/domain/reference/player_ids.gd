class_name PlayerIds
extends RefCounted
## lib/domain/reference/player_ids.dart: names the players of a game the
## same way in every game that plays the same moves. The id of the human is
## drawn at random when a game starts, so a snapshot writes it HUMAN; a
## faction keeps its id, which is made of its personality
## (`faction-pearlOrder`).

## What the human player's id is written as.
const HUMAN := "human"

var human_id: String


func _init(human_id_: String) -> void:
	human_id = human_id_


func of(id: String) -> String:
	return HUMAN if id == human_id else id


## `orNull`: `id` (a String or null) when it may be missing (a cell nobody
## took).
func or_null(id: Variant) -> Variant:
	if id == null:
		return null
	var text: String = id
	return of(text)

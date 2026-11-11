class_name HeldBy
extends RefCounted
## Who holds a post or the kernel, as the cell stores it (the id of a player,
## a String, or null while its guardians do): the player of [param game] it
## stands for, null for the guardians and for an id no player of the game has.


## The player [param id] stands for.
static func player(game: Game, id: Variant) -> Player:
	if id == null:
		return null
	return game.players.get(str(id))

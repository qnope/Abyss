class_name SavedGames
extends RefCounted
## What GameRepository.load_all found: the games it read, in the order they
## were first saved, and the files it could not read, which it skipped.

var games: Array[Game]
## Each file skipped, by its name, with why (SaveCodec), in the same order.
var unreadable: Dictionary[String, String]


func _init(games_: Array[Game] = [], unreadable_: Dictionary[String, String] = {}) -> void:
	games = games_
	unreadable = unreadable_

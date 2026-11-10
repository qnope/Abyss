class_name GameStatistics
extends RefCounted
## lib/domain/game/game_statistics.dart: what the end of a game tells the
## player.

var turns_played: int
var monsters_defeated: int
var bases_captured: int
var total_resources_collected: int
var raids_repelled: int
var raids_lost: int


func _init(
	turns_played_: int,
	monsters_defeated_: int,
	bases_captured_: int,
	total_resources_collected_: int,
	raids_repelled_ := 0,
	raids_lost_ := 0,
) -> void:
	turns_played = turns_played_
	monsters_defeated = monsters_defeated_
	bases_captured = bases_captured_
	total_resources_collected = total_resources_collected_
	raids_repelled = raids_repelled_
	raids_lost = raids_lost_

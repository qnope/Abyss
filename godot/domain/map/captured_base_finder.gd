class_name CapturedBaseFinder
extends RefCounted
## lib/domain/map/captured_base_finder.dart: finds the transition base of a
## level the player has captured.


## `CapturedBase`, the record of a post the player holds with where it
## stands.
class CapturedBase:
	var position: GridPosition
	var base: TransitionBase

	func _init(position_: GridPosition, base_: TransitionBase) -> void:
		position = position_
		base = base_


## The base of `level` held by `player_id`, row by row, or null when the
## level is unknown or its base is not captured.
static func on(game: Game, level: int, player_id: String) -> CapturedBase:
	var map: GameMap = game.levels.get(level)
	if map == null:
		return null
	for y: int in map.height:
		for x: int in map.width:
			var base := map.cell_at(x, y).transition_base
			if base != null and base.captured_by == player_id:
				return CapturedBase.new(GridPosition.new(x, y), base)
	return null

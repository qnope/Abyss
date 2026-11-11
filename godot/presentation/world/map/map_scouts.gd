class_name MapScouts
extends Node3D
## The scouts in transit on the map (lib/presentation/widgets/map/
## scout_token_layer.dart): a [ScoutToken] over each cell a scout was sent to
## and not back from. A scout sent while the level is shown swims there; the
## ones already sent when the level appears wait. A scout whose target is no
## longer pending (its exploration is over) leaves at once. The tokens never
## catch a tap: the map picks the cell under them.

## The scouts by the cell they were sent to.
var tokens: Dictionary[Vector2i, ScoutToken] = {}
var _level := 0


## Shows the scouts of [param pending] (each target with the cell its scout
## set off from) on the level [param level] of a map [param width] by
## [param height] cells.
func show_scouts(
	pending: Dictionary[Vector2i, Vector2i], level: int, width: int, height: int
) -> void:
	var appearing := level != _level
	_level = level
	for target: Vector2i in tokens.keys():
		if appearing or not pending.has(target):
			tokens[target].free()
			tokens.erase(target)
	for target: Vector2i in pending:
		if tokens.has(target):
			continue
		var token := ScoutToken.new(
			MapGrid.at(pending[target].x, pending[target].y, width, height),
			MapGrid.at(target.x, target.y, width, height), not appearing)
		tokens[target] = token
		add_child(token)
	set_process(_is_swimming())


func _process(delta: float) -> void:
	for token: ScoutToken in tokens.values():
		token.advance(delta)
	set_process(_is_swimming())


func _is_swimming() -> bool:
	return tokens.values().any(func(token: ScoutToken) -> bool: return token.is_swimming())

class_name FactionExploration
extends RefCounted
## lib/domain/faction/faction_exploration.dart: where a faction's scouts look
## first: towards the centre of the map, where the posts and the human wait,
## and along the diagonals of its own base rather than straight to the
## borders.
##
## A diagonal step reveals a fresh corner of the fog, while a border is a
## dead end that shows nothing of the others.

## Worth of one cell nearer the centre than the base.
const TOWARD_CENTRE := 0.5
## Cost of one cell off the diagonal of the base.
const OFF_DIAGONAL := 0.3


## Added to the number of fresh cells a target reveals.
static func bias(base: GridPosition, width: int, height: int, target: GridPosition) -> float:
	var cx := DartMath.quotient(width - 1, 2)
	var cy := DartMath.quotient(height - 1, 2)
	var nearer := _from_centre(base, cx, cy) - _from_centre(target, cx, cy)
	var gap := absi(absi(target.x - base.x) - absi(target.y - base.y))
	return TOWARD_CENTRE * nearer - OFF_DIAGONAL * gap


static func _from_centre(p: GridPosition, cx: float, cy: float) -> float:
	return maxf(absf(p.x - cx), absf(p.y - cy))


## The bias of the faction playing `turn`, for the base level.
static func for_turn(turn: ScriptTurn, target: GridPosition) -> float:
	var map: GameMap = turn.game.levels[1]
	return bias(
		GridPosition.new(turn.player.base_x, turn.player.base_y), map.width, map.height, target
	)

class_name TurnStorySnapshot
extends RefCounted
## What the story of a turn needs to know of the player before the turn ends
## (lib/presentation/screens/game/story/turn_story_snapshot.dart): the cells
## seen on each level, and where scouts wait. Taken before the turn, it is read
## against the player after it to tell what the turn showed.

## The cells seen on each level, by key.
var revealed: Dictionary[int, Dictionary] = {}
## The cells scouts were sent to, as (level, x, y).
var scouts: Dictionary[Vector3i, bool] = {}


## What [param player] has seen and sent exploring now.
static func of(player: Player) -> TurnStorySnapshot:
	var snapshot := TurnStorySnapshot.new()
	for level: int in player.revealed_cells_per_level:
		snapshot.revealed[level] = player.revealed_cells_set_on_level(level)
	for order in player.pending_explorations:
		snapshot.scouts[Vector3i(order.level, order.target.x, order.target.y)] = true
	return snapshot


## The cells [param player] has seen on [param level] since this snapshot, in the
## order they were seen.
func newly_seen(player: Player, level: int) -> Array[Vector2i]:
	var before: Dictionary = revealed.get(level, {})
	var found: Array[Vector2i] = []
	for cell in player.revealed_cells_on_level(level):
		if not before.has(cell.key()):
			found.append(cell.key())
	return found


## The cells of [param level] where a scout waited and waits no more for
## [param player].
func scouts_gone(player: Player, level: int) -> Array[Vector2i]:
	var still := TurnStorySnapshot.of(player).scouts
	var found: Array[Vector2i] = []
	for scout in scouts:
		if scout.x == level and not still.has(scout):
			found.append(Vector2i(scout.y, scout.z))
	return found

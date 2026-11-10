class_name MapLayout
extends RefCounted
## lib/domain/map/map_layout.dart: how a map grows with the number of
## players.

const MIN_PLAYERS := 1
const MAX_PLAYERS := 11
## What `size_for` and `extra_posts_for` answer to a number of players Dart
## throws an ArgumentError for.
const REFUSED := -1


## Side of the square map: 20 up to 3 players, 26 up to 6, 32 up to 11.
static func size_for(player_count: int) -> int:
	if not _check(player_count):
		return REFUSED
	if player_count <= 3:
		return 20
	return 26 if player_count <= 6 else 32


## Failles, and as many Cheminées, added to the usual ones: one for each two
## players past the first.
static func extra_posts_for(player_count: int) -> int:
	if not _check(player_count):
		return REFUSED
	return DartMath.trunc_div(player_count - 1, 2)


## Lairs a map may hold, the fewest (x) and the most (y): 5 to 10 on a
## 20 x 20 map, more on a larger one. Dart's record `(int, int)`.
static func lair_range_for(size: int) -> Vector2i:
	var area := size * size
	return Vector2i(DartMath.trunc_div(5 * area, 400), DartMath.trunc_div(10 * area, 400))


## Whether a game can have that many players; logs an error otherwise,
## where Dart throws.
static func _check(player_count: int) -> bool:
	if player_count < MIN_PLAYERS or player_count > MAX_PLAYERS:
		push_error("MapLayout: playerCount %d must be 1 to %d" % [player_count, MAX_PLAYERS])
		return false
	return true

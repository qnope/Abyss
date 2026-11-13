class_name StoryChapter
extends RefCounted
## One step of the story of a turn (lib/presentation/screens/game/story/
## story_chapter.dart): what the map tells on [member level], either the fog
## lifting from the cells a scout saw, or a siege of a place. The chapter only
## says what happens; [StoryPlayer] plays it with the map's effects.

## The level whose map tells it.
var level: int
## The siege to play, or null for the fog lifting.
var siege: MapSiege
## The cells seen during the turn, for the fog lifting.
var seen: Array[Vector2i] = []
## The cells where a scout waited and leaves with the fog.
var scouts: Array[Vector2i] = []


func _init(level_: int, siege_: MapSiege = null) -> void:
	level = level_
	siege = siege_


## The fog lifting from [param seen_] on [param level_], with the [param scouts_]
## that waited on them.
static func fog(level_: int, seen_: Array[Vector2i], scouts_: Array[Vector2i]) -> StoryChapter:
	var chapter := StoryChapter.new(level_)
	chapter.seen = seen_
	chapter.scouts = scouts_
	return chapter


## Whether this is the fog lifting.
func is_fog() -> bool:
	return siege == null

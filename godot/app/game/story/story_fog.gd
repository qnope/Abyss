class_name StoryFog
extends RefCounted
## The first chapter of a story (lib/presentation/screens/game/story/
## turn_story_fog.dart): the fog lifting from the cells the scouts saw during the
## turn, on the level where the most were seen. The map's own lift
## ([FogLifts]) plays it as the level is drawn; the chapter says which level to
## open and waits for it.


## The fog chapter of the turn of [param game], told from what the player had
## [param before] it, or null when no cell was seen.
static func chapter(game: Game, before: TurnStorySnapshot) -> StoryChapter:
	var human := game.human_player()
	var levels: Array[int] = []
	for level: int in game.levels:
		levels.append(level)
	levels.sort()
	var chosen := 0
	var seen: Array[Vector2i] = []
	for level in levels:
		var cells := before.newly_seen(human, level)
		if cells.size() > seen.size():
			chosen = level
			seen = cells
	if seen.is_empty():
		return null
	var scouts: Array[Vector2i] = []
	for cell in before.scouts_gone(human, chosen):
		if seen.has(cell):
			scouts.append(cell)
	return StoryChapter.fog(chosen, seen, scouts)

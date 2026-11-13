class_name TurnStory
extends RefCounted
## What the map tells at the end of a turn, before its summary
## (lib/presentation/screens/game/story/turn_story.dart): the fog lifting from the
## cells the scouts saw, then the raid fought on the base, then the school of
## predators, then the wave fought on the volcano, then the attacks of the
## factions (and of the guardians) on the human, as they were fought. Pure: it
## reads the game and the result, and plays nothing ([StoryPlayer] does).

var chapters: Array[StoryChapter] = []


## The story of the turn of [param game] that ended in [param result], told from
## what the player had [param before] it.
static func plan(game: Game, before: TurnStorySnapshot, result: TurnResult) -> TurnStory:
	var story := TurnStory.new()
	story._add(StoryFog.chapter(game, before))
	for raid: RaidReport in [result.raid, result.predators]:
		if raid != null:
			story._add(SiegeChapters.raid(game, raid))
	if result.volcano != null:
		story._add(SiegeChapters.volcano(game, result.volcano))
	for attack in result.attacks:
		story._add(SiegeChapters.attack(game, attack))
	return story


## Whether there is nothing to tell.
func is_empty() -> bool:
	return chapters.is_empty()


func _add(chapter: StoryChapter) -> void:
	if chapter != null:
		chapters.append(chapter)

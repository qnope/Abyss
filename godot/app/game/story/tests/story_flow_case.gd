class_name StoryFlowCase
extends PostControllerCase
## The base of the tests of the turn story on the screen: the game of PostControllerCase
## (the Faille of the first level and the volcano of the third seen), with the effects
## staged, which the fights' tests keep over at once.

var told := 0


func before_each() -> void:
	super()
	world.map.effects.reduced_motion = false


## A story of a siege of the base, then of the volcano, then of the base again.
func story_of_three() -> TurnStory:
	var story := TurnStory.new()
	story.chapters.append(siege_on(1, Vector2i(human.base_x, human.base_y)))
	story.chapters.append(siege_on(VOLCANO, kernel_at))
	story.chapters.append(siege_on(1, Vector2i(human.base_x, human.base_y)))
	return story


func siege_on(level: int, at: Vector2i) -> StoryChapter:
	var fight := StrikeSamples.fight([5, 3], [2, 1])
	return StoryChapter.new(level, MapSiege.by_wave(at, StrikeSamples.lair(), fight, true))


func player_of(story: TurnStory) -> StoryPlayer:
	return StoryPlayer.new(controller.map, story, func() -> void: told += 1)


## Plays the effect on the map to its end, as the frames would.
func run_effect() -> void:
	world.map.effects.current.advance(60.0)


## A cell next to the seen ones that a scout may have seen: the map lifts its fog.
func scout_sees() -> void:
	var seen := human.revealed_cells_set_on_level(1)
	var map: GameMap = game.levels[1]
	for y in map.height:
		for x in map.width:
			if not seen.has(Vector2i(x, y)) and CellEligibilityChecker.is_eligible(map, human, x, y):
				human.add_revealed_cell(1, GridPosition.new(x, y))
				return

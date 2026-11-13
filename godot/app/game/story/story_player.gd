class_name StoryPlayer
extends RefCounted
## Plays the chapters of a [TurnStory] on the map, one after the other
## (lib/presentation/screens/game/game_screen_story.dart: `tellTurnStory`): each
## chapter opens its level on the map (the Map tab, the level of the chapter, as
## Flutter's `showLevel`) and plays its effect, and the next begins when it is over.
##
## The effects are the map's ([MapEffects]), which are told the time frame by
## frame, so a test moves a chapter on with `effects.current.advance(seconds)`.
## The fog lifting is the map's own: drawing the level lifts the fog from the
## cells seen since it was last drawn, and the chapter waits for it.
##
## [method skip] ends the story at once: the effect playing is finished (its last
## moment shown), the others are never played and the map shows the game as it
## now is. The "then" is called once, whichever way the story ends, and never
## after [method cancel]. The chapters call the player back from the map's effects,
## which do not hold it: whoever plays a story keeps the player until it is over.

var _map: MapController
var _chapters: Array[StoryChapter]
var _then: Callable
var _next := 0
var _skipped := false
var _over := false


func _init(map: MapController, story: TurnStory, then: Callable) -> void:
	_map = map
	_chapters = story.chapters
	_then = then


## Plays the story from its first chapter.
func play() -> void:
	_step()


## Whether the story is over, told or skipped or cancelled.
func is_over() -> bool:
	return _over


## Ends the story at once, the summary can open.
func skip() -> void:
	if _over:
		return
	_skipped = true
	_map.finish_effects()
	_end()


## The screen is gone: nothing more is played and nothing is called.
func cancel() -> void:
	_over = true


func _step() -> void:
	if _over:
		return
	if _skipped or _next >= _chapters.size():
		_end()
		return
	var chapter := _chapters[_next]
	_next += 1
	_map.tell_level(chapter.level)
	if chapter.is_fog():
		_map.after_effects(_step)
	else:
		_map.siege(chapter.siege, _step)


func _end() -> void:
	if _over:
		return
	_over = true
	_then.call()

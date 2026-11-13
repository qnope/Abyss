class_name StoryTeller
extends RefCounted
## Tells the story of a turn on the map between the turn and its summary
## (lib/presentation/screens/game/game_screen_story.dart: `watchTurnStory`). It is
## the [member EndTurnFlow.observe] of the game screen: asked before the turn ends
## it notes what the player has seen, and given the turn's result afterwards it
## plans the story ([TurnStory]), floats the skip button over the map and plays
## the chapters ([StoryPlayer]). The summary opens when the story is over, skipped
## or not; a turn with nothing to tell opens it at once, and a player who asked
## for fewer animations is told no story and keeps the screen he was on.
##
## Leaving the map during the story ends it, since the world behind another tab
## is paused and the effects would never end.

var _game: Game
var _map: MapController
var _hud: GameHud
var _player: StoryPlayer
var _skip: StorySkipButton


func _init(game: Game, map: MapController, hud: GameHud) -> void:
	_game = game
	_map = map
	_hud = hud


## What [member EndTurnFlow.observe] calls before the turn ends: the Callable that
## tells it (taking the result and the "then"), or an invalid one.
func observe() -> Callable:
	if _map.is_reduced_motion():
		return Callable()
	return _tell.bind(TurnStorySnapshot.of(_game.human_player()))


## The screen is gone: the story is not told any more.
func close() -> void:
	if _player != null:
		_player.cancel()
	_leave()


func _tell(result: TurnResult, then: Callable, before: TurnStorySnapshot) -> void:
	var story := TurnStory.plan(_game, before, result)
	if story.is_empty():
		then.call()
		return
	_skip = StorySkipButton.new()
	_skip.float_in(_hud.content)
	_hud.tab_changed.connect(_on_tab_changed)
	_player = StoryPlayer.new(_map, story, _on_told.bind(then))
	_skip.skipped.connect(_player.skip)
	_player.play()


func _on_told(then: Callable) -> void:
	_leave()
	then.call()


## Takes the skip button and the listening away.
func _leave() -> void:
	if _skip != null:
		_skip.hide()
		_skip.queue_free()
		_skip = null
	if _hud.tab_changed.is_connected(_on_tab_changed):
		_hud.tab_changed.disconnect(_on_tab_changed)


func _on_tab_changed(tab: GameTab.Value) -> void:
	if tab != GameTab.Value.MAP:
		_player.skip()

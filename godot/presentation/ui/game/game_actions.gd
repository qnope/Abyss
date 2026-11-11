class_name GameActions
extends RefCounted
## Every change the player makes to the game goes through here: an action run
## by the ActionExecutor for the human, or a mark on the game (a switch of
## the guide, a tip seen, free play). Each tells [signal acted], which is
## Flutter's `onChanged` and `repository.save` in one: whoever keeps the game
## saves it and redraws, so that the UI never depends on `data/`
## (app/game/game_session.gd listens). The state of the screen itself (the
## tab on show, a selection) is not the game's and never goes through here.

## The game changed: [param result] is the action's ActionResult, null for a
## mark. Not told for an action that failed: it changed nothing.
signal acted(result: Variant)
## An action raised a kernel to the last level: the game is won (its status is
## VICTORY and [signal acted] has been told, so it is saved with it).
signal victory_reached

var game: Game
## What the guide of the tutorial points at, read again before [signal acted]
## reaches whoever saves and redraws (ui/guide/guide_scope.gd).
var guide: GuideScope
var _executor := ActionExecutor.new()


func _init(game_: Game) -> void:
	game = game_
	guide = GuideScope.new(game)
	acted.connect(guide.refresh)


## Runs [param action] for the human player and returns its result. A
## success is told with [signal acted], then the victory if it brought one
## (game_screen_actions.dart: showBuildingDetailAction); a failure is only
## returned, for the caller to explain.
func execute(action: Action) -> ActionResult:
	var result := _executor.execute(action, game, game.human_player())
	if result.is_success:
		var won: bool = VictoryChecker.check(game) == GameStatus.Value.VICTORY
		if won:
			game.status = GameStatus.Value.VICTORY
		acted.emit(result)
		if won:
			victory_reached.emit()
	return result


## Ends the turn of the game (game_screen_end_turn.dart: confirmAndEndTurn,
## once confirmed) with a die of its own, and returns what the turn did to the
## human's base. Told with [signal acted] like any action, so the game is saved.
func end_turn() -> TurnResult:
	var result := execute(EndTurnAction.new(SeededRandom.fresh()))
	return (result as EndTurnActionResult).turn_result


## Changes the game with [param change] (called with it), then tells it
## [signal acted] with no result.
func mark(change: Callable) -> void:
	change.call(game)
	acted.emit(null)


## Switches the tutorial guide on or off.
func set_guide_enabled(enabled: bool) -> void:
	mark(func(_game: Game) -> void: _objectives().tutorial_enabled = enabled)


## Switches the tip cards on or off.
func set_tips_enabled(enabled: bool) -> void:
	mark(func(_game: Game) -> void: _objectives().tips_enabled = enabled)


## Records the tip [param id] as seen.
func mark_tip_seen(id: TipId.Value) -> void:
	mark(func(_game: Game) -> void: _objectives().mark_seen(id))


## Records the tips [param ids] as seen, in one mark: one save.
func mark_tips_seen(ids: Array[TipId.Value]) -> void:
	mark(func(_game: Game) -> void:
		for id in ids:
			_objectives().mark_seen(id))


## Plays on after the victory.
func continue_in_free_play() -> void:
	mark(func(target: Game) -> void: target.status = GameStatus.Value.FREE_PLAY)


func _objectives() -> ObjectiveState:
	return ObjectiveMigration.state_of(game, game.human_player())

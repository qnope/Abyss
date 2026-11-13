class_name EndTurnFlow
extends RefCounted
## The player's "next turn" from the press to the next playable state
## (lib/presentation/screens/game/game_screen_end_turn.dart: confirmAndEndTurn,
## then game_screen_turn_flow.dart), a chain of signals with no await:
##
##     request() -> TurnConfirmation -> confirmed -> GameActions.end_turn()
##       -> turn_ended -> TurnOutcome (the summary, the reports, the tips)
##       -> finished, or defeated when the turn lost the game
##
## Cancelling, or dismissing the question, leaves the turn where it is.
##
## Whoever tells the turn's story on the map gives the flow an [member observe]
## (lib/presentation/screens/game/game_screen_end_turn.dart: `TurnObserver`): a
## Callable asked once the turn is confirmed, before it ends, that returns the
## Callable to call with the result and what to do next, or an invalid one when
## there is nothing to tell. The summary waits for that "next", which is told
## once, and no second turn can be asked meanwhile.
## [method GameActions.end_turn] tells `acted`, so whoever keeps the game has
## saved it and redrawn before the first page opens.

## The turn ended: [param result] is what it did to the human's base. The
## game has changed (the turn counter, the stocks) and is saved.
signal turn_ended(result: TurnResult)
## Every page of the outcome was seen and the game goes on.
signal finished
## The turn lost the game.
signal defeated

var actions: GameActions
var outcome: TurnOutcome
## Called before each turn: gives the Callable that tells it, or an invalid one.
var observe := Callable()
var _modals: ModalLayer
var _telling := false


func _init(actions_: GameActions, modals: ModalLayer) -> void:
	actions = actions_
	_modals = modals


## Asks the player to confirm the end of the turn, with what it will make and
## cost.
func request() -> void:
	if _telling:
		return
	var game := actions.game
	var dialog := TurnConfirmation.new(TurnForecast.of(game), TurnWarnings.of(game, game.human_player()))
	dialog.closed.connect(_on_answer)
	_modals.open(dialog)


func _on_answer(confirmed: Variant) -> void:
	if confirmed != true:
		return
	var tell: Callable = observe.call() if observe.is_valid() else Callable()
	var result := actions.end_turn()
	turn_ended.emit(result)
	if tell.is_valid():
		_telling = true
		tell.call(result, _after_story.bind(result))
	else:
		_open_outcome(result)


## The story of the turn [param result] is over: the pages open, once however
## many times the story says it.
func _after_story(result: TurnResult) -> void:
	if _telling:
		_telling = false
		_open_outcome(result)


## Opens the pages of the turn [param result].
func _open_outcome(result: TurnResult) -> void:
	outcome = TurnOutcome.new(actions.game, result, _modals, TurnOutcome.default_steps(actions))
	outcome.defeated.connect(defeated.emit)
	outcome.finished.connect(finished.emit)
	outcome.run()

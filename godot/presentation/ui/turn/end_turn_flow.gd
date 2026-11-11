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
var _modals: ModalLayer


func _init(actions_: GameActions, modals: ModalLayer) -> void:
	actions = actions_
	_modals = modals


## Asks the player to confirm the end of the turn, with what it will make and
## cost.
func request() -> void:
	var game := actions.game
	var dialog := TurnConfirmation.new(TurnForecast.of(game), TurnWarnings.of(game, game.human_player()))
	dialog.closed.connect(_on_answer)
	_modals.open(dialog)


func _on_answer(confirmed: Variant) -> void:
	if confirmed != true:
		return
	var result := actions.end_turn()
	turn_ended.emit(result)
	outcome = TurnOutcome.new(actions.game, result, _modals, TurnOutcome.default_steps(actions))
	outcome.defeated.connect(defeated.emit)
	outcome.finished.connect(finished.emit)
	outcome.run()

class_name EventStep
extends RefCounted
## The step of the `TurnOutcome` queue that shows the card of the event the
## turn drew (lib/presentation/screens/game/game_screen_turn_flow.dart:
## showTurnOutcome, its `openEventCard`): after the summary and the reports,
## and not for a game the turn lost. The card is a page like the others; its
## choice goes through the actions it is built with, so the game is changed
## and its save asked for before the queue goes on.


## The step for the game of [param actions]: a Callable taking the game and the
## turn's result and returning the card, or null when there is none to show.
static func of(actions: GameActions) -> Callable:
	return func(game: Game, result: TurnResult) -> ModalPanel: return page(actions, game, result)


## The card of the event [param result] drew, null when the turn drew none or
## [param game] was lost to it.
static func page(actions: GameActions, game: Game, result: TurnResult) -> ModalPanel:
	if result.event == null or game.status == GameStatus.Value.DEFEAT:
		return null
	var type: RandomEventType.Value = result.event
	return EventCard.new(actions, type)

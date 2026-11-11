class_name TipPresenter
extends RefCounted
## Opens the « première fois » tips of the human player of a game
## (lib/.../tip_presenter.dart): all the unseen ones whose situation is there,
## stacked in one [TipStack], saved as seen before it shows.
##
## Nothing is shown when the tips are off, when none is waiting, or once the
## game is over (won or lost, unless the play goes on after the victory).

var actions: GameActions


func _init(actions_: GameActions) -> void:
	actions = actions_


## The stack of the tips waiting, marked as seen and saved; null when there is
## none to show.
func next_stack() -> TipStack:
	var game := actions.game
	if game.status != GameStatus.Value.PLAYING and game.status != GameStatus.Value.FREE_PLAY:
		return null
	var tips := TipCatalog.pending_for(game, game.human_player())
	if tips.is_empty():
		return null
	var ids: Array[TipId.Value] = []
	for tip in tips:
		ids.append(tip.id)
	actions.mark_tips_seen(ids)
	return TipStack.new(tips)


## The step of the turn's pages that shows the tips waiting: a Callable taking
## the game and the turn's result and returning the stack, or null.
func step() -> Callable:
	return func(_game: Game, _result: TurnResult) -> ModalPanel: return next_stack()

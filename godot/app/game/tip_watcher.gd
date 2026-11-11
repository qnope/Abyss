class_name TipWatcher
extends RefCounted
## Opens the next tips after a player's action (lib/.../tip_presenter.dart,
## `showAfterAction`): once the change is saved and drawn, unless a page, a
## sheet or a dialog covers the screen by then (a fight, a report: the tips of
## a turn come last in its pages, [TipPresenter] and [TurnOutcome]).

var presenter: TipPresenter
var _session: GameSession
var _modals: ModalLayer


func _init(session: GameSession, modals: ModalLayer) -> void:
	_session = session
	_modals = modals
	presenter = TipPresenter.new(session.actions)
	_session.changed.connect(_queue)
	_queue()


## The screen is gone: nothing is listened to any more.
func close() -> void:
	_session.changed.disconnect(_queue)


## Looks for the tips once the frame is drawn.
func _queue() -> void:
	_show.call_deferred()


## Opens the stack of the tips waiting, if the screen is free for it.
func _show() -> void:
	if _modals.depth() > 0:
		return
	var stack := presenter.next_stack()
	if stack != null:
		_modals.open(stack)

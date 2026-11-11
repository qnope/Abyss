class_name ModalPanel
extends RefreshingPanel
## What the [ModalLayer] stacks: a dialog, a bottom sheet or a full page. It
## says where it sits ([member placement]), how large the area it may fill is
## ([method fit]) and, once, that it is over ([signal closed]) with a result
## (the action pressed, or null when it was dismissed): the caller connects
## to it and carries on, with no await.

enum Placement { CENTER, BOTTOM, FULL }

## The modal is over: [param result] is what the player chose, null for a
## dismissal. Emitted once.
signal closed(result: Variant)

var placement := Placement.CENTER
## Whether a touch outside it, or Escape, closes it (Flutter's
## barrierDismissible).
var dismissible := true

var _is_closed := false


## Ends the modal with [param result]; the layer then takes it off.
func close(result: Variant = null) -> void:
	if _is_closed:
		return
	_is_closed = true
	closed.emit(result)


## Whether [method close] has been called.
func is_closed() -> bool:
	return _is_closed


## Called by the layer with the [param area] it fills, when the modal opens
## and whenever the area changes: a modal that has a maximum size sets it.
func fit(_area: Vector2) -> void:
	pass

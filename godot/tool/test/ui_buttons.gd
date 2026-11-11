class_name UiButtons
extends RefCounted
## What a touch does to a button, for UiTestCase.press.


## The button [param node] is, or is drawn over; null for none.
static func under(node: Node) -> BaseButton:
	while node != null and not node is BaseButton:
		node = node.get_parent()
	return node as BaseButton


## Touches [param button] as a finger does: a toggle button changes state
## (the lit button of a group that does not let it go stays lit), then it
## emits `pressed`.
static func touch(button: BaseButton) -> void:
	if button.toggle_mode and not _is_held_in_group(button):
		button.button_pressed = not button.button_pressed
	button.pressed.emit()


## Whether [param button] is the lit one of a group that does not let it go.
static func _is_held_in_group(button: BaseButton) -> bool:
	var group := button.button_group
	return button.button_pressed and group != null and not group.allow_unpress

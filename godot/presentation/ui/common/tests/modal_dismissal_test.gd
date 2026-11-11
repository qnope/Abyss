extends UiTestCase
## How the player dismisses a modal: a touch on its scrim, or Escape, when it
## is dismissible and on top.


func test_a_touch_on_the_scrim_dismisses_the_modal_on_top_only() -> void:
	var first := AbyssDialog.new()
	var second := AbyssDialog.new()
	modals().open(first)
	modals().open(second)
	var scrims := _scrims()
	scrims[0].gui_input.emit(_touch(MOUSE_BUTTON_LEFT, true))
	assert_eq(modals().depth(), 2, "a scrim under another modal does nothing")
	scrims[1].gui_input.emit(_touch(MOUSE_BUTTON_RIGHT, true))
	scrims[1].gui_input.emit(_touch(MOUSE_BUTTON_LEFT, false))
	scrims[1].gui_input.emit(InputEventKey.new())
	assert_eq(modals().depth(), 2, "only a left press counts")
	scrims[1].gui_input.emit(_touch(MOUSE_BUTTON_LEFT, true))
	assert_eq(current_modal(), first)


func test_a_modal_that_is_not_dismissible_ignores_the_scrim_and_escape() -> void:
	var dialog := AbyssDialog.new()
	dialog.dismissible = false
	modals().open(dialog)
	_scrims()[0].gui_input.emit(_touch(MOUSE_BUTTON_LEFT, true))
	modals()._unhandled_input(_cancel())
	assert_eq(current_modal(), dialog)
	dialog.close()
	assert_null(current_modal())


func test_escape_dismisses_the_modal_on_top() -> void:
	modals()._unhandled_input(_cancel())
	modals().open(AbyssDialog.new())
	modals()._unhandled_input(InputEventKey.new())
	assert_eq(modals().depth(), 1, "another event does nothing")
	modals()._unhandled_input(_cancel())
	assert_eq(modals().depth(), 0)


func _scrims() -> Array[Panel]:
	var found: Array[Panel] = []
	for node in find_type("Panel", modals()):
		var panel := node as Panel
		if panel.theme_type_variation == &"ModalScrim":
			found.append(panel)
	return found


static func _touch(button: MouseButton, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = pressed
	return event


static func _cancel() -> InputEventAction:
	var event := InputEventAction.new()
	event.action = &"ui_cancel"
	event.pressed = true
	return event

extends UiTestCase
## The layer that stacks dialogs, sheets and pages over the screen: what it
## lets through, the scrim, the order, how a modal ends and how the next
## step of a flow follows, without an await.

var _results: Array = []


func test_is_invisible_to_touches_while_empty() -> void:
	var layer := modals()
	assert_eq(layer.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(layer.depth(), 0)
	assert_null(layer.top())
	layer.close_top()
	assert_eq(layer.depth(), 0, "closing nothing is harmless")


func test_opens_a_modal_over_a_scrim_that_catches_the_touches() -> void:
	var dialog := AbyssDialog.new("Title")
	modals().open(dialog)
	assert_eq(modals().depth(), 1)
	assert_eq(current_modal(), dialog)
	assert_eq(_scrims().size(), 1)
	assert_eq(_scrims()[0].mouse_filter, Control.MOUSE_FILTER_STOP)
	assert_not_null(find_text("Title"))


func test_stacks_the_modals_each_over_its_own_scrim() -> void:
	var first := AbyssDialog.new("First")
	var second := AbyssDialog.new("Second")
	modals().open(first)
	modals().open(second)
	assert_eq(modals().depth(), 2)
	assert_eq(current_modal(), second)
	assert_eq(modals().get_child_count(), 2)
	assert_eq(_scrims().size(), 2)
	modals().close_top()
	assert_eq(current_modal(), first)
	modals().close_top()
	assert_null(current_modal())


func test_close_top_tells_the_modal_is_over_with_no_result() -> void:
	var dialog := AbyssDialog.new()
	dialog.closed.connect(func(result: Variant) -> void: _results.append(result))
	modals().open(dialog)
	modals().close_top()
	assert_eq(_results, [null])
	assert_true(dialog.is_closed())
	assert_eq(modals().get_child_count(), 0, "taken off the layer")
	dialog.close("again")
	assert_eq(_results, [null], "told once")


func test_an_action_ends_a_dialog_with_its_result() -> void:
	var dialog := AbyssDialog.new("Delete?")
	dialog.add_action("No")
	dialog.add_action("Yes", "deleted")
	dialog.closed.connect(func(result: Variant) -> void: _results.append(result))
	modals().open(dialog)
	press("Yes")
	assert_eq(_results, ["deleted"])
	assert_eq(modals().depth(), 0)


func test_a_flow_chains_its_steps_by_signal() -> void:
	var first := AbyssDialog.new("Step one")
	first.add_action("Next", 1)
	var second := AbyssDialog.new("Step two")
	second.add_action("Done", 2)
	first.closed.connect(func(result: Variant) -> void:
		_results.append(result)
		modals().open(second))
	second.closed.connect(func(result: Variant) -> void: _results.append(result))
	modals().open(first)
	press("Next")
	assert_eq(current_modal(), second)
	press("Done")
	assert_eq(_results, [1, 2])
	assert_eq(modals().depth(), 0)





func test_places_each_modal_where_it_says() -> void:
	var centred := AbyssDialog.new()
	var sheet := BottomSheet.new()
	var page := FullPage.new()
	for modal: ModalPanel in [centred, sheet, page]:
		modals().open(modal)
	assert_eq(centred.anchor_left, 0.5)
	assert_eq(centred.anchor_top, 0.5)
	assert_eq(centred.grow_vertical, Control.GROW_DIRECTION_BOTH)
	assert_eq(sheet.anchor_top, 1.0)
	assert_eq(sheet.anchor_right, 1.0)
	assert_eq(sheet.grow_vertical, Control.GROW_DIRECTION_BEGIN)
	assert_eq([page.anchor_left, page.anchor_top, page.anchor_right, page.anchor_bottom],
		[0.0, 0.0, 1.0, 1.0])


func test_tells_a_modal_the_room_it_has_when_it_opens_and_when_it_changes() -> void:
	var dialog := AbyssDialog.new()
	modals().open(dialog)
	assert_eq(dialog.custom_minimum_size.x, AbyssDialog.width_in(modals().size))
	host().size = Vector2(1000.0, 700.0)
	assert_eq(dialog.custom_minimum_size.x, AbyssDialog.MAX_WIDTH)


func test_fades_a_modal_in_unless_animations_are_reduced() -> void:
	var layer := mount(ModalLayer.new()) as ModalLayer
	layer.open(AbyssDialog.new())
	var slot := layer.get_child(0) as Control
	assert_eq(slot.modulate.a, 0.0)
	layer.reduced_motion = true
	layer.open(AbyssDialog.new())
	assert_eq((layer.get_child(1) as Control).modulate.a, 1.0)


func _scrims() -> Array[Panel]:
	var found: Array[Panel] = []
	for node in find_type("Panel", modals()):
		var panel := node as Panel
		if panel.theme_type_variation == &"ModalScrim":
			found.append(panel)
	return found


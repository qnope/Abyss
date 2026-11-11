extends UiTestCase
## The sheet rising from the bottom edge: full width, its handle on top, its
## body scrolling past 90 % of the screen, dismissed by a pull on the handle.


func test_is_a_themed_sheet_along_the_bottom_with_a_handle() -> void:
	var sheet := mount(BottomSheet.new()) as BottomSheet
	assert_eq(sheet.theme_type_variation, &"BottomSheetPanel")
	assert_eq(sheet.placement, ModalPanel.Placement.BOTTOM)
	assert_true(sheet.handle.is_visible_in_tree())
	assert_eq(sheet.handle.get_child_count(), 1)
	var bar := sheet.handle.get_child(0) as Panel
	var look := bar.get_theme_stylebox(&"panel") as StyleBoxFlat
	assert_eq(look.bg_color, AbyssCardTheme.DRAG_HANDLE)
	assert_eq(bar.custom_minimum_size, Vector2(40.0, 4.0))


func test_holds_the_content_in_its_body() -> void:
	var sheet := mount(BottomSheet.new()) as BottomSheet
	var line := Label.new()
	line.text = "Details"
	sheet.body.add_child(line)
	assert_eq(find_text("Details", sheet), line)


func test_is_as_wide_as_the_screen_and_scrolls_past_ninety_percent() -> void:
	var sheet := mount(BottomSheet.new()) as BottomSheet
	var tall := Control.new()
	tall.custom_minimum_size.y = 3000.0
	sheet.body.add_child(tall)
	sheet.fit(Vector2(390.0, 800.0))
	assert_eq(sheet.custom_minimum_size.x, 390.0)
	assert_true(sheet.get_combined_minimum_size().y <= 800.0 * BottomSheet.MAX_HEIGHT_SHARE + 1.0)
	assert_true(sheet.get_combined_minimum_size().y > 600.0)


func test_a_pull_down_on_the_handle_dismisses_it() -> void:
	var sheet := mount(BottomSheet.new()) as BottomSheet
	var results := []
	sheet.closed.connect(func(result: Variant) -> void: results.append(result))
	_drag(sheet.handle, 10.0)
	assert_eq(results, [], "too short")
	_drag(sheet.handle, -120.0)
	assert_eq(results, [], "upwards")
	_drag(sheet.handle, BottomSheet.DISMISS_PULL)
	assert_eq(results, [null])


func test_a_sheet_that_is_not_dismissible_stays_when_pulled() -> void:
	var sheet := mount(BottomSheet.new()) as BottomSheet
	sheet.dismissible = false
	_drag(sheet.handle, 200.0)
	assert_false(sheet.is_closed())


func test_the_handle_tells_how_far_a_drag_went() -> void:
	var handle := mount(SheetDragHandle.new()) as SheetDragHandle
	var pulls: Array[float] = []
	handle.pulled.connect(func(distance: float) -> void: pulls.append(distance))
	handle.gui_input.emit(_button(false, 5.0))
	handle.gui_input.emit(_motion(30.0))
	assert_eq(pulls.size(), 0, "a release without a press is no drag")
	_drag(handle, 42.0)
	_drag(handle, -8.0)
	assert_eq(pulls, [42.0, -8.0])
	assert_eq(handle.custom_minimum_size.y, SheetDragHandle.ROW_HEIGHT)
	var bar := (handle.get_child(0) as Panel).get_theme_stylebox(&"panel") as StyleBoxFlat
	assert_eq(bar.bg_color, AbyssCardTheme.SHEET_HANDLE)


func test_the_handle_ignores_other_buttons_and_motion_without_a_press() -> void:
	var handle := mount(SheetDragHandle.new()) as SheetDragHandle
	var pulls: Array[float] = []
	handle.pulled.connect(func(distance: float) -> void: pulls.append(distance))
	var right := _button(true, 0.0)
	right.button_index = MOUSE_BUTTON_RIGHT
	handle.gui_input.emit(right)
	handle.gui_input.emit(_motion(50.0))
	handle.gui_input.emit(_button(false, 50.0))
	assert_eq(pulls.size(), 0)


## A drag of [param distance] pixels down on [param handle], press to release.
func _drag(handle: SheetDragHandle, distance: float) -> void:
	handle.gui_input.emit(_button(true, 4.0))
	handle.gui_input.emit(_motion(4.0 + distance))
	handle.gui_input.emit(_button(false, 4.0 + distance))


static func _button(pressed: bool, y: float) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = Vector2(20.0, y)
	return event


static func _motion(y: float) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.position = Vector2(20.0, y)
	return event


func test_measures_its_chrome_again_once_laid_out() -> void:
	var sheet := mount(BottomSheet.new()) as BottomSheet
	var scroll := sheet._scroll as ScrollBody
	sheet.fit(Vector2(400.0, 800.0))
	sheet.body.add_child(Label.new())
	sheet.resized.emit()
	var chrome := sheet.get_combined_minimum_size().y - scroll.custom_minimum_size.y
	assert_almost_eq(scroll.max_height, maxf(800.0 * BottomSheet.MAX_HEIGHT_SHARE - chrome, 0.0), 0.5)

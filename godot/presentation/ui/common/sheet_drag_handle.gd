class_name SheetDragHandle
extends CenterContainer
## The small bar on top of a bottom sheet, telling it can be dragged down
## (lib/presentation/widgets/common/sheet_drag_handle.dart). A drag that
## starts on it tells how far it went down when it ends ([signal pulled]):
## the sheet closes when that is far enough. The row is 32 high where
## Flutter's bar has 8 above and 4 below, so that a finger finds it.

## The handle was released after a drag; [param distance] is how far down it
## went, negative when up.
signal pulled(distance: float)

const ROW_HEIGHT := 32.0

var _start := 0.0
var _distance := 0.0
var _dragging := false


func _init(color := AbyssCardTheme.SHEET_HANDLE) -> void:
	custom_minimum_size.y = ROW_HEIGHT
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bar := Panel.new()
	bar.custom_minimum_size = Vector2(AbyssCardTheme.HANDLE_SIZE)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_theme_stylebox_override(&"panel", AbyssBox.flat(color, AbyssCardTheme.HANDLE_SIZE.y / 2))
	add_child(bar)
	gui_input.connect(_on_gui_input)


func _on_gui_input(event: InputEvent) -> void:
	var button := event as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT:
		if button.pressed:
			_dragging = true
			_start = button.position.y
			_distance = 0.0
		elif _dragging:
			_dragging = false
			pulled.emit(_distance)
	var motion := event as InputEventMouseMotion
	if motion != null and _dragging:
		_distance = motion.position.y - _start

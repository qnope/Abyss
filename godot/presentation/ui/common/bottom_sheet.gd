class_name BottomSheet
extends ModalPanel
## A sheet rising from the bottom edge (Flutter's modal bottom sheet with its
## drag handle): the full width of the screen, as tall as its body up to 90 %
## of the screen, then the body scrolls. Dragging the handle down far enough
## ends it, like a touch outside; fill [member body] with the content.

## How far down the handle is dragged to dismiss the sheet.
const DISMISS_PULL := 64.0
## The share of the screen's height it may take before its body scrolls.
const MAX_HEIGHT_SHARE := 0.9

## The content, under the handle.
var body: VBoxContainer
var handle := SheetDragHandle.new(AbyssCardTheme.DRAG_HANDLE)
var _scroll := ScrollBody.new()


func _init() -> void:
	super()
	placement = Placement.BOTTOM
	theme_type_variation = &"BottomSheetPanel"
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 0)
	column.add_child(handle)
	column.add_child(_scroll)
	add_child(column)
	body = _scroll.content
	handle.pulled.connect(_pulled)


func fit(area: Vector2) -> void:
	custom_minimum_size.x = area.x
	var chrome := get_combined_minimum_size().y - _scroll.custom_minimum_size.y
	_scroll.max_height = maxf(area.y * MAX_HEIGHT_SHARE - chrome, 0.0)


func _pulled(distance: float) -> void:
	if dismissible and distance >= DISMISS_PULL:
		close()

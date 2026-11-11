class_name CellInfoSheet
extends MapSheet
## What a touch on a cell with nothing to do opens: a picture, a title and a
## message (lib/presentation/widgets/map/cell_info_sheet.dart): your base, a
## cell already visited, a plain, a passage. Both texts are written by a
## function, so that the sheet follows the language.

var message_label: Label


## A sheet with [param picture] (a control, or null), the title
## [param title] and the message [param message] (functions with no argument
## returning a String).
func _init(picture: Control, title: Callable, message: Callable) -> void:
	super(picture, title)
	message_label = label(message)
	message_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	column.add_child(message_label)

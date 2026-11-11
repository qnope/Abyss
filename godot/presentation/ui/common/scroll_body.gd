class_name ScrollBody
extends ScrollContainer
## A column of content that is as tall as it needs, up to [member max_height],
## then scrolls: the body of a dialog or of a bottom sheet. Add the content
## to [member content].

var content := VBoxContainer.new()
## The tallest it grows to, in pixels; the content scrolls beyond it.
var max_height := INF:
	set(value):
		max_height = value
		_fit()


func _init() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.minimum_size_changed.connect(_fit)
	add_child(content)


## A ScrollContainer is as small as it may be: it takes its content's height,
## up to the maximum.
func _fit() -> void:
	custom_minimum_size.y = minf(content.get_combined_minimum_size().y, max_height)

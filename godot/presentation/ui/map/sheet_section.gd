class_name SheetSection
extends RefreshingPanel
## A part of a map sheet that has its own state (the defence of a post, the
## garrison of the kernel): a column of rows, the texts written by functions
## (a call to [Texts]) so that [method refresh] writes them all again on a
## change of the language, as [MapSheet] does for its own. A section makes its
## labels and buttons with [method label] and [method button]; what a rebuilt
## part shows, such as a panel of units, goes through [method swap].

const GAP := 8

var column := VBoxContainer.new()
var _labels: Dictionary[Label, Callable] = {}
var _buttons: Dictionary[Button, Callable] = {}
var _swaps: Dictionary[Control, Callable] = {}


func _init() -> void:
	super()
	column.add_theme_constant_override(&"separation", GAP)
	add_child(column)


## A label written by [param source], in the style [param variation] and the
## ink [param color]. It is not added to the column.
func label(source: Callable, variation := &"", color := AbyssColors.ON_SURFACE) -> Label:
	var made := Label.new()
	made.theme_type_variation = variation
	made.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	made.add_theme_color_override(&"font_color", color)
	made.text = source.call()
	_labels[made] = source
	return made


## A button written by [param source]. It is not added to the column.
func button(source: Callable) -> Button:
	var made := Button.new()
	made.text = source.call()
	_buttons[made] = source
	return made


## A holder whose one child is what [param source] builds, built again by
## every [method refresh]. It is not added to the column.
func swap(source: Callable) -> Control:
	var holder := VBoxContainer.new()
	var built: Control = source.call()
	holder.add_child(built)
	_swaps[holder] = source
	return holder


func refresh() -> void:
	for made: Label in _labels:
		made.text = _labels[made].call()
	for made: Button in _buttons:
		made.text = _buttons[made].call()
	for holder: Control in _swaps:
		for old in holder.get_children():
			holder.remove_child(old)
			old.free()
		var built: Control = _swaps[holder].call()
		holder.add_child(built)

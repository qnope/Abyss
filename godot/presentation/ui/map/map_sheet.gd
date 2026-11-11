class_name MapSheet
extends BottomSheet
## The base of the sheets a touch on a cell of the map opens: a picture, a
## title in the cyan of the headlines and a column of rows, padded as the
## sheets of the base are. A text is written by a function (a call to [Texts]),
## so that [method refresh] writes them all again when the language changes: a
## sheet makes its labels and buttons with [method label] and [method button].
## [method tell] says why an action was refused, in a line above the button.

const PAD := 24
const BOTTOM_PAD := 32
const GAP := 8

var column := VBoxContainer.new()
var title_label: Label
## Why the last action was refused, hidden until [method tell] writes it.
var failure_label := Label.new()
var _labels: Dictionary[Label, Callable] = {}
var _buttons: Dictionary[Button, Callable] = {}


## A sheet with [param picture] (a control, or null) over a title written by
## [param title] (a function with no argument returning a String; none for a
## picture that names itself, and [member title_label] is then null).
func _init(picture: Control, title: Callable) -> void:
	super()
	column.add_theme_constant_override(&"separation", GAP)
	var padding := MarginContainer.new()
	for side: String in ["left", "right"]:
		padding.add_theme_constant_override("margin_" + side, PAD)
	padding.add_theme_constant_override(&"margin_bottom", BOTTOM_PAD)
	padding.add_child(column)
	body.add_child(padding)
	if picture != null:
		column.add_child(picture)
	if not title.is_null():
		title_label = label(title, &"HeadlineSmall")
		title_label.add_theme_color_override(&"font_color", AbyssColors.BIOLUM_CYAN)
		column.add_child(title_label)
	failure_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	failure_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	failure_label.add_theme_color_override(&"font_color", AbyssColors.WARNING)
	failure_label.visible = false


func _notification(what: int) -> void:
	super(what)
	# A sheet that never says why an action was refused does not place the line.
	if what == NOTIFICATION_PREDELETE and failure_label.get_parent() == null:
		failure_label.free()


## A centred label written by [param source], in the style [param variation]
## (the plain one when empty). It is not added to the column.
func label(source: Callable, variation := &"") -> Label:
	var made := Label.new()
	made.theme_type_variation = variation
	made.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	made.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	made.text = source.call()
	_labels[made] = source
	return made


## A button written by [param source]. It is not added to the column.
func button(source: Callable) -> Button:
	var made := Button.new()
	made.text = source.call()
	_buttons[made] = source
	return made


## Says that the action was refused for [param reason].
func tell(reason: ActionFailure.Value) -> void:
	_labels[failure_label] = func() -> String: return ActionFailureTexts.message(reason)
	failure_label.visible = true
	refresh()


## Writes every text again, in the language on.
func refresh() -> void:
	for made: Label in _labels:
		made.text = _labels[made].call()
	for made: Button in _buttons:
		made.text = _buttons[made].call()

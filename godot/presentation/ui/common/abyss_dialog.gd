class_name AbyssDialog
extends ModalPanel
## A dialog in the middle of the screen (Flutter's Dialog and AlertDialog):
## a title, a body that scrolls when it is taller than the room, and actions
## on a row at the right. Fill [member body] with the content and add the
## actions; pressing an action ends the dialog with its result.
##
##     var dialog := AbyssDialog.new(Texts.t(&"commonConfirm"))
##     dialog.body.add_child(label)
##     dialog.add_action(Texts.t(&"commonCancel"))
##     dialog.add_action(Texts.t(&"commonOk"), true, &"")
##     dialog.closed.connect(func(result: Variant) -> void: ...)
##     layer.open(dialog)
##
## Its texts are written once. A dialog that must follow the language
## overrides [method refresh] and sets them again.

## The room left on each side of the screen, and the dialog's widths.
const MARGIN := 40.0
const MIN_WIDTH := 280.0
const MAX_WIDTH := 560.0
## The share of the screen's height it may take before its body scrolls.
const MAX_HEIGHT_SHARE := 0.9

## The content, above the actions.
var body: VBoxContainer
var _title := Label.new()
var _scroll := ScrollBody.new()
var _actions := HBoxContainer.new()
var _area := Vector2.ZERO


func _init(title_text := "") -> void:
	super()
	placement = Placement.CENTER
	theme_type_variation = &"DialogPanel"
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", AbyssCardTheme.GAP)
	_title.theme_type_variation = &"DialogTitle"
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_actions.alignment = BoxContainer.ALIGNMENT_END
	_actions.add_theme_constant_override(&"separation", AbyssCardTheme.ACTION_GAP)
	column.add_child(_title)
	column.add_child(_scroll)
	column.add_child(_actions)
	add_child(column)
	body = _scroll.content
	set_title(title_text)
	# Once laid out, the texts wrap at their true width: the chrome is measured again.
	resized.connect(_refit)


## Writes the title; none is shown when it is empty.
func set_title(text: String) -> void:
	_title.text = text
	_title.visible = not text.is_empty()


## The title written.
func title() -> String:
	return _title.text


## Adds a button to the actions that ends the dialog with [param result]
## when pressed, in the Button variation [param variation] (the text button
## by default, &"" for the filled one).
func add_action(label: String, result: Variant = null, variation := &"TextButton") -> Button:
	var button := add_button(label, variation)
	button.pressed.connect(close.bind(result))
	return button


## Adds a button to the actions that does not end the dialog: whoever adds it
## connects its `pressed`.
func add_button(label: String, variation := &"TextButton") -> Button:
	var button := Button.new()
	button.text = label
	button.theme_type_variation = variation
	_actions.add_child(button)
	return button


## The actions added, left to right.
func actions() -> Array[Button]:
	var found: Array[Button] = []
	for child in _actions.get_children():
		found.append(child as Button)
	return found


## The width of a dialog in an [param area]: the screen's less its margins,
## between the minimum and the maximum.
static func width_in(area: Vector2) -> float:
	return clampf(area.x - 2.0 * MARGIN, MIN_WIDTH, MAX_WIDTH)


func fit(area: Vector2) -> void:
	_area = area
	custom_minimum_size.x = width_in(area)
	var chrome := get_combined_minimum_size().y - _scroll.custom_minimum_size.y
	_scroll.max_height = maxf(area.y * MAX_HEIGHT_SHARE - chrome, 0.0)


func _refit() -> void:
	fit(_area)

class_name FullPage
extends ModalPanel
## A page over the whole screen (Flutter's Scaffold with an AppBar, pushed as
## a route): an app bar with a back button at the left and a centred title,
## and a body that scrolls. The back button ends the page with a null result.
## Fill [member body] with the content.

## The content, under the app bar, padded.
var body: VBoxContainer
var back_button: Button
var _bar := PageBar.new()
var _scroll := ScrollBody.new()


func _init(title_text := "") -> void:
	super()
	placement = Placement.FULL
	theme_type_variation = AbyssSurfaceTheme.PAGE
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 0)
	column.add_child(_bar)
	back_button = _bar.back_button
	_bar.back_pressed.connect(close)
	# Taller than the room, the body scrolls: it does not push the page.
	_scroll.max_height = 0.0
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_scroll)
	add_child(column)
	var padding := MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		padding.add_theme_constant_override("margin_" + side, AbyssCardTheme.GAP)
	body = VBoxContainer.new()
	padding.add_child(body)
	_scroll.content.add_child(padding)
	set_title(title_text)


## Writes the title in the app bar.
func set_title(text: String) -> void:
	_bar.set_title(text)


func title() -> String:
	return _bar.title()

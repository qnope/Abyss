class_name ScreenPage
extends RefreshingPanel
## A screen of the app that is a page (Flutter's Scaffold with an AppBar, a
## route of the Navigator): an app bar with a back arrow and a centred title
## over a [member body] that fills the rest, on a veil that dims the world
## behind it. Unlike a FullPage it is not stacked on a ModalLayer: the app
## shows one screen at a time. Back (the arrow, or Escape) tells
## [signal back_pressed]; whoever shows the page decides where it leads.
##
## The title is an ARB key, so that it follows the language.

signal back_pressed

## Where a screen puts its content, under the app bar.
var body := PanelContainer.new()
var bar := PageBar.new()
var _title_key: StringName


func _init(title_key: StringName, dimmed := true) -> void:
	# Before super(): it switches the automatic translation off, which tells
	# the node, and so calls refresh().
	_title_key = title_key
	super()
	if dimmed:
		var veil := Panel.new()
		veil.theme_type_variation = AbyssSurfaceTheme.SCRIM
		veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(veil)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 0)
	bar.back_pressed.connect(back_pressed.emit)
	body.theme_type_variation = AbyssSurfaceTheme.BARE
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(bar)
	column.add_child(body)
	add_child(column)
	refresh()


func refresh() -> void:
	bar.set_title(Texts.t(_title_key))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and is_visible_in_tree():
		back_pressed.emit()
		get_viewport().set_input_as_handled()

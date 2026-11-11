class_name KitGallery
extends Control
## The UI kit laid out for review (tool/scene_capture.sh renders it): the small
## components of presentation/ui/common on two pages, then a dialog, a bottom
## sheet and a full page over a ModalLayer. Review tooling, not game code.

const PAGE_A := 0
const PAGE_B := 1

var modals := ModalLayer.new()
var _page := VBoxContainer.new()


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = AbyssTheme.build()
	var backdrop := PanelContainer.new()
	backdrop.theme_type_variation = AbyssSurfaceTheme.PAGE
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_page.add_theme_constant_override(&"separation", 10)
	var margin := MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	margin.add_child(_page)
	backdrop.add_child(margin)
	add_child(backdrop)
	add_child(modals)


## Shows page [param index] ([constant PAGE_A] or [constant PAGE_B]).
func show_page(index: int) -> void:
	for child in _page.get_children():
		_page.remove_child(child)
		child.free()
	var parts := KitParts.new()
	for part in (parts.page_a() if index == PAGE_A else parts.page_b()):
		_page.add_child(part)


## Opens a dialog, a bottom sheet or a full page ([param kind] "dialog",
## "sheet", "page") over the page.
func open_modal(kind: String) -> void:
	var parts := KitParts.new()
	match kind:
		"dialog":
			modals.open(parts.dialog())
		"sheet":
			modals.open(parts.sheet())
		_:
			modals.open(parts.full_page())

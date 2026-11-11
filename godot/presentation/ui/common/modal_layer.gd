class_name ModalLayer
extends Control
## Stacks dialogs, bottom sheets and full pages over the screen, each over a
## scrim of its own, the last opened on top: [method open] a [ModalPanel],
## [method close_top] ends the top one. A modal ends itself with
## [method ModalPanel.close] and its [signal ModalPanel.closed] tells its
## caller, so a flow is a chain of signals, never an await.
##
## The layer lets touches through while it is empty, so the screen below
## stays alive, and swallows them while a modal is open. A touch on a scrim,
## or Escape, closes the top modal when it is [member ModalPanel.dismissible].

## Fewer animations: a modal shows at once instead of fading in.
var reduced_motion := false

var _stack: Array[Entry] = []


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	resized.connect(_fit_all)


## Shows [param modal] over everything open.
func open(modal: ModalPanel) -> void:
	var slot := Control.new()
	slot.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var scrim := Panel.new()
	scrim.theme_type_variation = AbyssSurfaceTheme.SCRIM
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.gui_input.connect(_scrim_input.bind(modal))
	slot.add_child(scrim)
	slot.add_child(modal)
	_place(modal)
	var entry := Entry.new(modal, slot)
	_stack.append(entry)
	add_child(slot)
	modal.closed.connect(_remove.bind(entry), CONNECT_ONE_SHOT)
	modal.fit(size)
	var fade := AbyssMotion.or_instant(AbyssMotion.QUICK, reduced_motion)
	if fade > 0.0:
		slot.modulate.a = 0.0
		var tween := slot.create_tween().set_trans(AbyssMotion.ENTER_TRANS)
		tween.set_ease(AbyssMotion.ENTER_EASE)
		tween.tween_property(slot, "modulate:a", 1.0, fade)


## Ends the top modal with a null result; nothing when none is open.
func close_top() -> void:
	var modal := top()
	if modal != null:
		modal.close()


## The modal on top, or null when none is open.
func top() -> ModalPanel:
	if _stack.is_empty():
		return null
	var entry: Entry = _stack.back()
	return entry.modal


## How many modals are open.
func depth() -> int:
	return _stack.size()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and top() != null and top().dismissible:
		close_top()
		get_viewport().set_input_as_handled()


func _scrim_input(event: InputEvent, modal: ModalPanel) -> void:
	var touch := event as InputEventMouseButton
	if touch != null and touch.pressed and touch.button_index == MOUSE_BUTTON_LEFT \
			and modal == top() and modal.dismissible:
		modal.close()


func _remove(_result: Variant, entry: Entry) -> void:
	_stack.erase(entry)
	remove_child(entry.slot)
	entry.slot.queue_free()


func _fit_all() -> void:
	for entry in _stack:
		entry.modal.fit(size)


## Puts [param modal] where its placement says: centred, along the bottom
## edge growing up, or over the whole layer.
static func _place(modal: ModalPanel) -> void:
	match modal.placement:
		ModalPanel.Placement.CENTER:
			modal.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
			modal.grow_horizontal = Control.GROW_DIRECTION_BOTH
			modal.grow_vertical = Control.GROW_DIRECTION_BOTH
		ModalPanel.Placement.BOTTOM:
			modal.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
			modal.grow_vertical = Control.GROW_DIRECTION_BEGIN
		ModalPanel.Placement.FULL:
			modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## A modal and the node that holds it with its scrim.
class Entry:
	var modal: ModalPanel
	var slot: Control

	func _init(panel: ModalPanel, holder: Control) -> void:
		modal = panel
		slot = holder

class_name UiTestCase
extends TestCase
## The base of the tests of UI components (tool/test/README.md): it mounts a
## component in a window that wears the game's theme, finds a node by its
## text, its type or its name, presses a button, reads the modal on top and
## the texts shown, and puts the language back to French afterwards.
##
## Tests run in one frame: no container has laid its children out and no tween
## has moved, so read what a component sets (texts, states, signals).

## The size of the window a component is mounted in: a phone held upright.
const PHONE := Vector2(390.0, 844.0)

var _host: Control
var _layer: ModalLayer


## Adds [param component] to the window and returns it. The window is freed
## after the test, with whatever is mounted.
func mount(component: Control) -> Control:
	host().add_child(component)
	return component


## The window: a Control the size of a phone with the game's theme, in the
## scene tree's root, and no automatic translation, as under the real app.
func host() -> Control:
	if _host == null:
		_host = Control.new()
		_host.theme = AbyssTheme.build()
		_host.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		_host.size = PHONE
		(Engine.get_main_loop() as SceneTree).root.add_child(_host)
		add_cleanup(_unmount)
	return _host


## The layer modals open on, mounted over the window the first time.
func modals() -> ModalLayer:
	if _layer == null:
		_layer = ModalLayer.new()
		_layer.reduced_motion = true
		host().add_child(_layer)
	return _layer


## The modal on top, or null when none is open.
func current_modal() -> ModalPanel:
	return modals().top()


## The first node under [param root] (the window by default) that shows
## [param text] and is visible: a label, a button, a rich text or a field.
func find_text(text: String, root: Node = null) -> Control:
	for node in _shown(root):
		if _text_of(node) == text:
			return node
	return null


## The texts shown under [param root] (the window by default), in tree order.
func texts(root: Node = null) -> PackedStringArray:
	var found := PackedStringArray()
	for node in _shown(root):
		found.append(str(_text_of(node)))
	return found


## Every node of [param type] (a class name) under [param root] (the
## window by default), in tree order.
func find_type(type: String, root: Node = null) -> Array[Node]:
	return (root if root != null else host()).find_children("*", type, true, false)


## The first node called [param node_name] under [param root] (the window by
## default), or null.
func find_named(node_name: String, root: Node = null) -> Node:
	return (root if root != null else host()).find_child(node_name, true, false)


## Presses [param target]: a button, or the text of a button shown. A toggle
## button changes state as a touch does (the lit button of a group stays
## lit). A player cannot press a button that is disabled or hidden, nor one
## that is not there: the test fails.
func press(target: Variant) -> void:
	var button: BaseButton = target if target is BaseButton else null
	if target is String:
		var shown: String = target
		button = find_text(shown) as BaseButton
	if button == null:
		fail("press: no button for %s" % TestValues.describe(target))
	elif button.disabled or not button.is_visible_in_tree():
		fail("press: %s is %s" % [button.name, "disabled" if button.disabled else "hidden"])
	else:
		if button.toggle_mode and not _is_held_in_group(button):
			button.button_pressed = not button.button_pressed
		button.pressed.emit()


## The text the game writes for [param key]: what a component must show.
func text(key: StringName, args: Dictionary = {}) -> String:
	return Texts.t(key, args)


## Changes the game's language to [param code] ("fr", "en", "es") and tells
## every mounted node, as the app does when the player picks another.
func use_language(code: String) -> void:
	add_cleanup(AppLocale.debug_reset)
	TranslationServer.set_locale(code)


## Fails the test for each text shown under [param root] that is an ARB key
## written as it is, which means a component forgot to ask [Texts].
func assert_no_raw_keys(root: Node = null) -> void:
	for shown in texts(root):
		if Texts.has(StringName(shown), "fr"):
			fail('"%s" is shown as the key it should have been translated from' % shown)


## Whether [param button] is the lit one of a group that does not let it go.
static func _is_held_in_group(button: BaseButton) -> bool:
	var group := button.button_group
	return button.button_pressed and group != null and not group.allow_unpress


func _unmount() -> void:
	_host.free()
	_host = null
	_layer = null


## The nodes that show a text and are visible, in tree order.
func _shown(root: Node) -> Array[Control]:
	var found: Array[Control] = []
	var start := root if root != null else host()
	var all := start.find_children("*", "Control", true, false)
	all.push_front(start)
	for node in all:
		var control := node as Control
		if control != null and _text_of(control) != null and control.is_visible_in_tree():
			found.append(control)
	return found


## What [param node] shows, or null when it shows no text.
static func _text_of(node: Control) -> Variant:
	if node is Label or node is BaseButton or node is RichTextLabel or node is LineEdit:
		var shown: String = node.get("text")
		return shown if not shown.is_empty() else null
	return null

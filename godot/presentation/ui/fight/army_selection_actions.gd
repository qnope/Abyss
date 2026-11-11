class_name ArmySelectionActions
extends RefreshingPanel
## The bottom of an army selection
## (lib/presentation/widgets/fight/army_selection_actions.dart): the warning
## that an assault needs an admiral, the button that launches the fight (off
## while no unit is picked) and the one that cancels it. It only tells what
## the player touched.

signal launch_requested
signal cancel_requested

const GAP := 12

## The ARB key of the launch button's text.
var launch_key: StringName
var launch_button := Button.new()
var cancel_button := Button.new()
var admiral_label := Label.new()


func _init(launch_key_: StringName) -> void:
	launch_key = launch_key_
	super()
	admiral_label.theme_type_variation = &"BodySmall"
	admiral_label.add_theme_color_override(&"font_color", AbyssColors.WARNING)
	admiral_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	admiral_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	admiral_label.visible = false
	launch_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	launch_button.disabled = true
	launch_button.pressed.connect(launch_requested.emit)
	cancel_button.theme_type_variation = &"TextButton"
	cancel_button.pressed.connect(cancel_requested.emit)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override(&"separation", GAP)
	buttons.add_child(launch_button)
	buttons.add_child(cancel_button)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", GAP)
	column.add_child(admiral_label)
	column.add_child(buttons)
	add_child(column)
	refresh()


## Lets the player launch, or not: some units are picked.
func set_ready(ready: bool) -> void:
	launch_button.disabled = not ready


## Shows the warning that the assault needs an admiral, or hides it.
func set_admiral_missing(missing: bool) -> void:
	admiral_label.visible = missing


func refresh() -> void:
	admiral_label.text = Texts.t(&"fightAdmiralRequired")
	launch_button.text = Texts.t(launch_key)
	cancel_button.text = Texts.t(&"commonCancel")

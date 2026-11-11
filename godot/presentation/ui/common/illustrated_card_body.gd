class_name IllustratedCardBody
extends VBoxContainer
## What an [IllustratedCard] holds, without its dialog, for a card that brings
## its own frame (lib/.../illustrated_card.dart, IllustratedCardBody): an
## illustration, a centred title, a few short lines, then its actions stacked
## full width. The illustration is any control: a [UiIcon] of an event or a
## faction, or a [Portrait].

const ILLUSTRATION_SIZE := 160.0
const GAP := 8
const ACTIONS_GAP := 16

var title_label := Label.new()
var line_labels: Array[Label] = []
var _actions := VBoxContainer.new()


func _init(illustration: Control, title: String, lines: PackedStringArray) -> void:
	add_theme_constant_override(&"separation", GAP)
	illustration.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(illustration)
	title_label.text = title
	title_label.theme_type_variation = &"HeadlineSmall"
	title_label.add_theme_color_override(&"font_color", AbyssColors.BIOLUM_CYAN)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(title_label)
	for line in lines:
		var label := Label.new()
		label.text = line
		label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line_labels.append(label)
		add_child(label)
	_actions.add_theme_constant_override(&"separation", GAP)
	var gap := Control.new()
	gap.custom_minimum_size.y = ACTIONS_GAP - GAP
	add_child(gap)
	add_child(_actions)


## Adds [param button] under the others, as wide as the card.
func add_action(button: Button) -> void:
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_actions.add_child(button)


## The actions, top to bottom.
func actions() -> Array[Button]:
	var found: Array[Button] = []
	for child in _actions.get_children():
		found.append(child as Button)
	return found

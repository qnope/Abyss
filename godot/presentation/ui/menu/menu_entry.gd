class_name MenuEntry
extends Button
## A large full-width menu button, with an optional second line (such as the
## game a "continue" resumes) and an optional count badge
## (lib/presentation/widgets/menu/menu_button.dart: MenuButton, which Godot's
## own MenuButton name rules out). Its texts are labels drawn over the
## button, so that it can hold two lines and a badge.

## PRIMARY: the glowing cyan fill, the action the screen suggests. OUTLINED:
## a dark pane rimmed with cyan, the other choices.
enum Look { PRIMARY, OUTLINED }

## The height of the button with a second line.
const TWO_LINES_HEIGHT := 72.0

var look: Look
var label := Label.new()
var subtitle_label := Label.new()
## The count badge, null when the count is zero.
var badge: CountBadge


## [param badge_count] is shown in a badge after the label, unless zero.
func _init(label_text: String, look_ := Look.PRIMARY, subtitle := "", badge_count := 0) -> void:
	look = look_
	var primary := look == Look.PRIMARY
	theme_type_variation = &"MenuPrimaryButton" if primary else &"MenuOutlinedButton"
	custom_minimum_size.y = AbyssMenuTheme.BUTTON_MIN_HEIGHT
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	focus_mode = Control.FOCUS_ALL
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var padding := AbyssMenuTheme.BUTTON_PADDING
	margin.add_theme_constant_override(&"margin_left", padding.x)
	margin.add_theme_constant_override(&"margin_right", padding.x)
	margin.add_theme_constant_override(&"margin_top", padding.y)
	margin.add_theme_constant_override(&"margin_bottom", padding.y)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override(&"separation", 0)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override(&"separation", 10)
	label.theme_type_variation = &"MenuPrimaryLabel" if primary else &"MenuButtonLabel"
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(label)
	if badge_count > 0:
		var tint := AbyssMenuTheme.PRIMARY_INK if primary else AbyssMenuTheme.CYAN
		badge = CountBadge.new(badge_count, tint)
		row.add_child(badge)
	subtitle_label.theme_type_variation = &"MenuPrimarySubtitle" if primary else &"MenuButtonSubtitle"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	subtitle_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(row)
	column.add_child(subtitle_label)
	margin.add_child(column)
	add_child(margin)
	set_label(label_text)
	set_subtitle(subtitle)


## Writes the first line, which a screen reader reads as the button's name.
func set_label(text_written: String) -> void:
	label.text = text_written
	accessibility_name = text_written


## Writes the second line; none is shown, and the button stays low, when it is
## empty.
func set_subtitle(text_written: String) -> void:
	subtitle_label.text = text_written
	subtitle_label.visible = not text_written.is_empty()
	custom_minimum_size.y = TWO_LINES_HEIGHT if subtitle_label.visible \
		else AbyssMenuTheme.BUTTON_MIN_HEIGHT

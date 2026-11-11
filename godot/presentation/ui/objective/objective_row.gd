class_name ObjectiveRow
extends MarginContainer
## One objective of the list (lib/.../objective_row.dart): its status glyph,
## its title, the reward it pays and, at the end of the row, its progress when
## it is the current one.

const ICON_SIZE := 18.0
const GAP := 8
const PADDING := 4

var status: ObjectiveStatus.Value
var icon: UiIcon
var title_label := Label.new()
var rewards: ResourceGainsRow
var progress_label: Label


## A row titled [param title] in [param status_]; [param progress] (an
## [ObjectiveProgress], or null) is shown at its end and [param reward] under
## the title when it is not empty.
func _init(title: String, status_: ObjectiveStatus.Value, progress: ObjectiveProgress = null,
		reward: Dictionary[ResourceType.Value, int] = {}) -> void:
	status = status_
	add_theme_constant_override(&"margin_top", PADDING)
	add_theme_constant_override(&"margin_bottom", PADDING)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var color := ObjectiveStatus.text_color(status)
	icon = UiIcon.glyph(ObjectiveStatus.glyph(status), ICON_SIZE, ObjectiveStatus.icon_color(status))
	icon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	title_label.text = title
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_color_override(&"font_color", color)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(title_label)
	if not reward.is_empty():
		rewards = ResourceGainsRow.new(reward)
		column.add_child(rewards)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	row.add_child(icon)
	row.add_child(column)
	if progress != null:
		progress_label = Label.new()
		progress_label.text = str(progress)
		progress_label.add_theme_color_override(&"font_color", color)
		row.add_child(progress_label)
	add_child(row)

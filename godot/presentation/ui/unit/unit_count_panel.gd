class_name UnitCountPanel
extends PanelContainer
## A framed list of units by type, the biggest group first, under a title with
## the total. The types without a unit are left out; with nobody at all, the
## empty message shows in alert colours in place of the rows
## (lib/presentation/widgets/unit/unit_count_panel.dart).

const RADIUS := 14
const PADDING := Vector2i(12, 8)
const FILL_ALPHA := 0.6
const ALERT_RIM_ALPHA := 0.55
const BAR_SIZE := Vector2(70.0, 6.0)
const COUNT_WIDTH := 40.0
const PORTRAIT_SIZE := 34.0
const GAP := 10

var title: String
var total := 0
var alert: bool
var total_label := Label.new()
## The type of each row, from the biggest group down.
var rows: Array[UnitType.Value] = []


func _init(title_: String, units: Dictionary[UnitType.Value, int], empty_message := "") -> void:
	title = title_
	for type: UnitType.Value in units:
		if units[type] > 0:
			rows.append(type)
			total += units[type]
	# No two types share a place: the count, then the type, tell them apart.
	rows.sort_custom(func(a: UnitType.Value, b: UnitType.Value) -> bool:
		return units[a] > units[b] or (units[a] == units[b] and a < b))
	alert = rows.is_empty() and not empty_message.is_empty()
	var accent := AbyssColors.CORAL_PINK if alert else AbyssColors.ENERGY_YELLOW
	var rim := Color(accent, ALERT_RIM_ALPHA) if alert else AbyssColors.TRENCH
	var box := AbyssBox.flat(Color(AbyssColors.DEEP_NAVY, FILL_ALPHA), RADIUS, PADDING)
	add_theme_stylebox_override(&"panel", AbyssBox.rimmed(box, rim))
	var column := VBoxContainer.new()
	var head := HBoxContainer.new()
	var title_label := Label.new()
	title_label.text = title
	title_label.theme_type_variation = &"TitleSmall"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	total_label.text = str(total)
	total_label.theme_type_variation = &"TitleMedium"
	total_label.add_theme_color_override(&"font_color", accent)
	head.add_child(title_label)
	head.add_child(total_label)
	column.add_child(head)
	if alert:
		var empty := Label.new()
		empty.text = empty_message
		empty.theme_type_variation = &"BodySmall"
		empty.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(empty)
	for type in rows:
		column.add_child(_row(type, units[type], units[rows[0]]))
	add_child(column)


func _row(type: UnitType.Value, count: int, biggest: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	var name_label := Label.new()
	name_label.text = UnitTexts.display_name(type)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var bar := ProgressBar.new()
	bar.custom_minimum_size = BAR_SIZE
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.show_percentage = false
	bar.max_value = biggest
	bar.value = count
	var count_label := Label.new()
	count_label.text = str(count)
	count_label.theme_type_variation = &"TitleMedium"
	count_label.custom_minimum_size.x = COUNT_WIDTH
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	for part: Control in [UnitPortrait.of(type, PORTRAIT_SIZE), name_label, bar, count_label]:
		row.add_child(part)
	return row

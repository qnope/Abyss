class_name FactionCountPicker
extends RefreshingPanel
## How many rival factions a new game has, from [constant MIN] to
## [constant MAX], one touch at a time
## (lib/presentation/widgets/common/faction_count_picker.dart). It keeps the
## count, and [signal changed] tells each change of it.

signal changed(count: int)

const MIN := 0
const MAX := 10
const GAP := 8
const ICON_SIZE := 24.0

var count: int
var title_label := Label.new()
var count_label := Label.new()
var description_label := Label.new()
var minus := Button.new()
var plus := Button.new()
var _minus_icon := UiIcon.glyph(&"remove", ICON_SIZE, AbyssColors.ON_SURFACE)
var _plus_icon := UiIcon.glyph(&"add", ICON_SIZE, AbyssColors.ON_SURFACE)


func _init(count_: int) -> void:
	super()
	count = clampi(count_, MIN, MAX)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", GAP)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_label.theme_type_variation = &"TitleMedium"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_label.theme_type_variation = &"HeadlineSmall"
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_label.custom_minimum_size.x = 48.0
	description_label.theme_type_variation = &"BodySmall"
	description_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_arrange(minus, _minus_icon, -1)
	_arrange(plus, _plus_icon, 1)
	row.add_child(minus)
	row.add_child(count_label)
	row.add_child(plus)
	column.add_child(title_label)
	column.add_child(row)
	column.add_child(description_label)
	add_child(column)
	refresh()


func refresh() -> void:
	title_label.text = Texts.t(&"newGameFactions")
	count_label.text = str(count)
	minus.disabled = count <= MIN
	plus.disabled = count >= MAX
	_minus_icon.self_modulate = AbyssColors.DISABLED if minus.disabled else AbyssColors.ON_SURFACE
	_plus_icon.self_modulate = AbyssColors.DISABLED if plus.disabled else AbyssColors.ON_SURFACE
	description_label.text = Texts.t(&"newGameFactionsNone") if count == 0 \
		else Texts.t(&"newGameFactionsCount", {"count": count})


func _arrange(button: Button, icon: UiIcon, step: int) -> void:
	button.theme_type_variation = &"TextButton"
	var touch := AbyssHudTheme.TOUCH_SIZE
	button.custom_minimum_size = Vector2(touch, touch)
	icon.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	button.add_child(icon)
	button.pressed.connect(_step.bind(step))


func _step(by: int) -> void:
	count = clampi(count + by, MIN, MAX)
	refresh()
	changed.emit(count)

class_name TipGuideRow
extends Button
## One tip of the Guide (lib/.../tip_guide.dart, `_TipTile`): its picture and
## its title once seen, to open its card again; a greyed « ??? » before.

const ICON_SIZE := 36.0
const GAP := 12

var tip: Tip
var seen: bool
var title_label := Label.new()


func _init(tip_: Tip, seen_: bool) -> void:
	tip = tip_
	seen = seen_
	theme_type_variation = AbyssSurfaceTheme.TAP
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	disabled = not seen
	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override(&"separation", GAP)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if seen:
		row.add_child(TipIllustrations.new().of(tip.id, ICON_SIZE))
		title_label.text = TipTexts.title(tip.id)
		row.add_child(title_label)
		row.add_child(UiIcon.glyph(&"chevron_right", 24.0, AbyssColors.ON_SURFACE_DIM))
	else:
		row.add_child(UiIcon.glyph(&"help_outline", ICON_SIZE, AbyssColors.DISABLED))
		title_label.text = "???"
		title_label.add_theme_color_override(&"font_color", AbyssColors.DISABLED)
		row.add_child(title_label)
	custom_minimum_size.y = ICON_SIZE + GAP
	add_child(row)
	accessibility_name = title_label.text

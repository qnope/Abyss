class_name ThreatBanner
extends PanelContainer
## The strip under the resource bar for a threat on its way, edged in its
## colour: a title in that colour, a detail line under it, and a chevron when
## a touch opens more (lib/.../threat_banner.dart).

## A touch on the banner; only a tappable one can emit it.
signal tapped

const EDGE := 4
const PADDING := Vector2i(12, 6)
const GAP := 8
const ICON_SIZE := 18.0

var title_label := Label.new()
var detail_label := Label.new()
## The touch area over the banner, null when it is not tappable.
var tap: Button


## A banner with the icon in the file [param icon_path], [param title] and
## [param detail]; [param tappable] adds the chevron and makes it a button.
func _init(
	icon_path: String, title: String, detail: String, color: Color, tappable := false
) -> void:
	var box := AbyssBox.flat(AbyssColors.SURFACE_DIM, 0, PADDING)
	box.border_width_left = EDGE
	box.border_color = color
	box.set_content_margin(SIDE_LEFT, PADDING.x + EDGE)
	add_theme_stylebox_override(&"panel", box)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	var lines := VBoxContainer.new()
	lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.text = title
	title_label.add_theme_color_override(&"font_color", color)
	detail_label.text = detail
	lines.add_child(title_label)
	lines.add_child(detail_label)
	row.add_child(UiIcon.new(icon_path, ICON_SIZE, color))
	row.add_child(lines)
	if tappable:
		row.add_child(UiIcon.glyph(&"chevron_right", 24.0, AbyssColors.ON_SURFACE_DIM))
	add_child(row)
	if tappable:
		tap = Button.new()
		tap.theme_type_variation = AbyssSurfaceTheme.TAP
		tap.accessibility_name = title
		tap.pressed.connect(tapped.emit)
		add_child(tap)

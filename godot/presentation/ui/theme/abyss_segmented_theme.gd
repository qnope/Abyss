class_name AbyssSegmentedTheme
## Look of a bar of segments floating over a view, one of them selected,
## such as the places of the army, ported from
## lib/presentation/theme/abyss_segmented_theme.dart: a dark translucent
## tray (the SegmentedTray panel) of toggle buttons sharing a ButtonGroup
## (the Segment button), the pressed one lit in cyan, with an optional
## detail below its name (the SegmentName and SegmentDetail labels).
##
## The tray's height is the node's custom_minimum_size, which a theme
## cannot set. A segment's detail turns ON_SELECTED with it: the scene
## sets that colour, since a Label does not follow its button's state.

## Height of the tray.
const HEIGHT := 40.0
## Corner radius of the tray, and of the selected segment inside it.
const RADIUS := 12.0
const SEGMENT_RADIUS := 9.0
## Gap between the tray's edge and the selected segment.
const INSET := 4.0

## The tray, nearly opaque so that the view behind stays a hint.
const TRAY := Color("0d1b2aeb")
const TRAY_EDGE := AbyssColors.SURFACE_LIGHT

## The selected segment, and the texts on it.
const SELECTED := AbyssColors.BIOLUM_CYAN
const ON_SELECTED := Color("03202a")

## The name of a segment, and the detail below it, such as a count.
const LABEL_COLOR := Color("9fb8d6")
const DETAIL_COLOR := Color("5e7da3")

const SEGMENT := &"Segment"


## Adds the tray, the segment and its detail to [param theme].
static func apply(theme: Theme) -> void:
	theme.set_type_variation(&"SegmentedTray", &"PanelContainer")
	var inset := Vector2i(roundi(INSET), roundi(INSET))
	var tray := AbyssBox.flat(TRAY, roundi(RADIUS), inset)
	theme.set_stylebox(&"panel", &"SegmentedTray", AbyssBox.rimmed(tray, TRAY_EDGE))
	theme.set_type_variation(SEGMENT, &"Button")
	var unlit := _segment(Color.TRANSPARENT)
	for state: StringName in [&"normal", &"hover", &"disabled"]:
		theme.set_stylebox(state, SEGMENT, unlit)
	for state: StringName in [&"pressed", &"hover_pressed"]:
		theme.set_stylebox(state, SEGMENT, _segment(SELECTED))
	theme.set_stylebox(&"focus", SEGMENT, StyleBoxEmpty.new())
	const BOLD := AbyssFonts.Weight.BOLD
	AbyssTextStyle.new(13, BOLD, LABEL_COLOR).apply_to(theme, SEGMENT)
	theme.set_color(&"font_hover_color", SEGMENT, LABEL_COLOR)
	theme.set_color(&"font_pressed_color", SEGMENT, ON_SELECTED)
	theme.set_color(&"font_hover_pressed_color", SEGMENT, ON_SELECTED)
	const SEMI_BOLD := AbyssFonts.Weight.SEMI_BOLD
	var detail := AbyssTextStyle.new(11, SEMI_BOLD, DETAIL_COLOR)
	AbyssTextTheme.add_label(theme, &"SegmentDetail", detail)
	AbyssTextTheme.add_label(theme, &"SegmentName", AbyssTextStyle.new(13, BOLD, LABEL_COLOR))


## A segment's box, filled with [param fill]: its name 4 pixels in from
## its sides.
static func _segment(fill: Color) -> StyleBoxFlat:
	return AbyssBox.flat(fill, roundi(SEGMENT_RADIUS), Vector2i(4, 0))

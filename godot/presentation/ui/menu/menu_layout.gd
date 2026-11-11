class_name MenuLayout
extends PanelContainer
## Arranges a full-screen menu over the 3D world
## (lib/presentation/widgets/menu/menu_layout.dart): the header near the top,
## the actions stacked at the bottom above an optional footer, leaving the
## middle of the world in view, and an optional corner (a discreet button)
## in the top right corner, above the scroll.
##
## The column keeps to [constant MAX_WIDTH], centred on wide screens. On a
## screen too short for it all, the free middle shrinks first, the spacing
## tightens below [constant COMPACT_HEIGHT] (a phone held sideways), then the
## whole menu scrolls.

const MAX_WIDTH := 420.0
## The room kept on each side of the column.
const SIDE := 24
## Share of the height left above the header.
const HEADER_TOP_SHARE := 0.1
## Room always kept between the header and the actions.
const MIN_MIDDLE_GAP := 24
## Height under which every gap of the menu tightens.
const COMPACT_HEIGHT := 480.0

var column := VBoxContainer.new()
var _top := MarginContainer.new()
var _middle := Control.new()
var _actions := VBoxContainer.new()
var _footer_gap := Control.new()
var _bottom := Control.new()


func _init(header: Control, actions: Array[Control], footer: Control = null,
		corner: Control = null) -> void:
	theme_type_variation = AbyssSurfaceTheme.BARE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var frame := MarginContainer.new()
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_theme_constant_override(&"separation", 0)
	_top.add_child(header)
	_middle.custom_minimum_size.y = MIN_MIDDLE_GAP
	_middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_actions.add_theme_constant_override(&"separation", int(AbyssMenuTheme.BUTTON_GAP))
	for action in actions:
		_actions.add_child(action)
	column.add_child(_top)
	column.add_child(_middle)
	column.add_child(_actions)
	_footer_gap.visible = footer != null
	column.add_child(_footer_gap)
	if footer != null:
		column.add_child(footer)
	column.add_child(_bottom)
	frame.add_child(column)
	scroll.add_child(frame)
	add_child(scroll)
	if corner != null:
		corner.size_flags_horizontal = Control.SIZE_SHRINK_END
		corner.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		add_child(corner)
	resized.connect(func() -> void: fit(size))
	fit(Vector2(MAX_WIDTH, COMPACT_HEIGHT))


## Sizes the column and its gaps for an [param area]: at most
## [constant MAX_WIDTH] wide, its spacing tight when the area is short.
func fit(area: Vector2) -> void:
	var compact := area.y < COMPACT_HEIGHT
	column.custom_minimum_size.x = minf(area.x, MAX_WIDTH) - 2.0 * SIDE
	_top.add_theme_constant_override(&"margin_top",
		12 if compact else roundi(maxf(16.0, area.y * HEADER_TOP_SHARE)))
	_middle.custom_minimum_size.y = 12.0 if compact else float(MIN_MIDDLE_GAP)
	_actions.add_theme_constant_override(&"separation",
		8 if compact else int(AbyssMenuTheme.BUTTON_GAP))
	_footer_gap.custom_minimum_size.y = 10.0 if compact else 20.0
	_bottom.custom_minimum_size.y = 8.0 if compact else 16.0

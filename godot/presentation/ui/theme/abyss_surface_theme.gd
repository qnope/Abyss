class_name AbyssSurfaceTheme
## The surfaces under and between the components, where Flutter leaves them
## to Material: the scrim behind a modal (a Panel variation, ModalScrim),
## the darker veil of a screen over the world (PageVeil),
## the panel that draws nothing and only lays its content out (BarePanel),
## the page of a full-screen modal, abyss black (PagePanel),
## the button that is only a touch area, lit while pointed at or pressed
## (TapSurface, Flutter's InkWell), the divider of dividerColor
## (HSeparator, VSeparator) and the scrollbars, thin and cyan.

const CYAN := AbyssColors.BIOLUM_CYAN

const SCRIM := &"ModalScrim"
const VEIL := &"PageVeil"
const BARE := &"BarePanel"
const PAGE := &"PagePanel"
const TAP := &"TapSurface"
## Material's barrier colour, black at 54 %.
const SCRIM_COLOR := Color(0, 0, 0, 0.54)
## What a screen's forms and lists read on: the world shows through, dim.
const VEIL_COLOR := Color(0, 0, 0, 0.8)
const DIVIDER := Color(CYAN, 0.1)
## Width of a scrollbar's grabber.
const SCROLL_WIDTH := 6


## Adds the surfaces to [param theme].
static func apply(theme: Theme) -> void:
	theme.set_type_variation(SCRIM, &"Panel")
	theme.set_stylebox(&"panel", SCRIM, AbyssBox.flat(SCRIM_COLOR, 0))
	theme.set_type_variation(VEIL, &"Panel")
	theme.set_stylebox(&"panel", VEIL, AbyssBox.flat(VEIL_COLOR, 0))
	theme.set_type_variation(BARE, &"PanelContainer")
	theme.set_stylebox(&"panel", BARE, StyleBoxEmpty.new())
	theme.set_type_variation(PAGE, &"PanelContainer")
	theme.set_stylebox(&"panel", PAGE, AbyssBox.flat(AbyssColors.ABYSS_BLACK, 0))
	_tap(theme)
	for type: StringName in [&"HSeparator", &"VSeparator"]:
		var line := StyleBoxLine.new()
		line.color = DIVIDER
		line.thickness = 1
		line.vertical = type == &"VSeparator"
		theme.set_stylebox(&"separator", type, line)
	for type: StringName in [&"VScrollBar", &"HScrollBar"]:
		_scrollbar(theme, type)


static func _tap(theme: Theme) -> void:
	theme.set_type_variation(TAP, &"Button")
	for state: StringName in [&"normal", &"disabled", &"focus"]:
		theme.set_stylebox(state, TAP, StyleBoxEmpty.new())
	var overlay := AbyssButtonLook.HOVER_OVERLAY
	theme.set_stylebox(&"hover", TAP, AbyssBox.flat(Color(AbyssColors.ON_SURFACE, overlay), 0))
	var pressed := AbyssBox.flat(Color(AbyssColors.ON_SURFACE, AbyssButtonLook.PRESS_OVERLAY), 0)
	for state: StringName in [&"pressed", &"hover_pressed"]:
		theme.set_stylebox(state, TAP, pressed)


static func _scrollbar(theme: Theme, type: StringName) -> void:
	theme.set_stylebox(&"scroll", type, StyleBoxEmpty.new())
	theme.set_stylebox(&"scroll_focus", type, StyleBoxEmpty.new())
	var inset := Vector2i(SCROLL_WIDTH / 2, SCROLL_WIDTH / 2)
	theme.set_stylebox(&"grabber", type, AbyssBox.flat(Color(CYAN, 0.3), 3, inset))
	theme.set_stylebox(&"grabber_highlight", type, AbyssBox.flat(Color(CYAN, 0.45), 3, inset))
	theme.set_stylebox(&"grabber_pressed", type, AbyssBox.flat(Color(CYAN, 0.6), 3, inset))

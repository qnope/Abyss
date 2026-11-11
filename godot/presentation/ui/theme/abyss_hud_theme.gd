class_name AbyssHudTheme
## The panels laid over the 3D world, such as the frame counter, which the
## Flutter game had no need of: a translucent abyss panel faintly rimmed in
## cyan, so that the world shows through, and the compact text styles of
## the figures it shows, and HudToggle, a button that is on or off, its
## "on" tinted and rimmed in cyan rather than filled, so that a panel of
## switches stays light over the world.

## The panel, and its content's gap from its sides (x) and its top (y).
const PANEL_FILL := Color(AbyssColors.ABYSS_BLACK, 0.72)
const PANEL_EDGE := Color(AbyssColors.BIOLUM_CYAN, 0.18)
const PANEL_RADIUS := 12
const PANEL_PADDING := Vector2i(12, 8)
## The smallest side of a control a finger presses, in points.
const TOUCH_SIZE := 44.0
## The gap between two controls of a panel.
const GAP := 6

const PANEL := &"HudPanel"
const TOGGLE := &"HudToggle"
## The strips of the game screen: the resource bar over the world, a veil of
## abyss black (padded 8 and 6), and the row of the turn counter and the next
## turn button over the tabs, deep navy (padded 12 and 6).
const RESOURCE_BAR := &"ResourceBarPanel"
const ACTION_ROW := &"ActionRowPanel"
const RESOURCE_BAR_FILL := Color(AbyssColors.ABYSS_BLACK, 0.9)
const RESOURCE_BAR_PADDING := Vector2i(8, 6)
const ACTION_ROW_PADDING := Vector2i(12, 6)
## A toggle on: a tint and a rim of cyan, its name in cyan; off: only a
## faint rim, its name dim.
const TOGGLE_TINT := Color(AbyssColors.BIOLUM_CYAN, 0.14)
const TOGGLE_EDGE := Color(AbyssColors.BIOLUM_CYAN, 0.7)
const TOGGLE_IDLE_EDGE := Color(AbyssColors.BIOLUM_CYAN, 0.12)
const TOGGLE_RADIUS := 9


## Adds the panel and its text styles to [param theme].
static func apply(theme: Theme) -> void:
	theme.set_type_variation(PANEL, &"PanelContainer")
	var panel := AbyssBox.flat(PANEL_FILL, PANEL_RADIUS, PANEL_PADDING)
	theme.set_stylebox(&"panel", PANEL, AbyssBox.rimmed(panel, PANEL_EDGE))
	const BOLD := AbyssFonts.Weight.BOLD
	const SEMI := AbyssFonts.Weight.SEMI_BOLD
	# The headline figure, such as the frames per second; a line of figures
	# under it; a name or a unit, quieter than the figures.
	var styles: Dictionary[StringName, AbyssTextStyle] = {
		&"HudHeadline": AbyssTextStyle.new(20, BOLD, AbyssColors.BIOLUM_CYAN),
		&"HudFigure": AbyssTextStyle.new(12, SEMI, AbyssColors.ON_SURFACE),
		&"HudCaption": AbyssTextStyle.new(11, SEMI, AbyssColors.ON_SURFACE_DIM, 1),
		# The turn counter; an amount of the resource bar, which takes its
		# resource's colour, and the rate of production under it.
		&"HudTurn": AbyssTextStyle.new(16, BOLD, AbyssColors.BIOLUM_CYAN, 1),
		&"ResourceAmount": AbyssTextStyle.new(14, BOLD, AbyssColors.ON_SURFACE),
		&"ResourceRate": AbyssTextStyle.new(11, AbyssFonts.Weight.DEFAULT, AbyssColors.ON_SURFACE_DIM),
	}
	for name in styles:
		AbyssTextTheme.add_label(theme, name, styles[name])
	_toggle(theme)
	theme.set_type_variation(RESOURCE_BAR, &"PanelContainer")
	theme.set_stylebox(&"panel", RESOURCE_BAR, AbyssBox.flat(RESOURCE_BAR_FILL, 0, RESOURCE_BAR_PADDING))
	theme.set_type_variation(ACTION_ROW, &"PanelContainer")
	theme.set_stylebox(&"panel", ACTION_ROW, AbyssBox.flat(AbyssColors.DEEP_NAVY, 0, ACTION_ROW_PADDING))


static func _toggle(theme: Theme) -> void:
	theme.set_type_variation(TOGGLE, &"Button")
	var padding := Vector2i(8, 0)
	var off := AbyssBox.rimmed(AbyssBox.flat(Color.TRANSPARENT, TOGGLE_RADIUS, padding),
		TOGGLE_IDLE_EDGE)
	var on := AbyssBox.rimmed(AbyssBox.flat(TOGGLE_TINT, TOGGLE_RADIUS, padding), TOGGLE_EDGE)
	for state: StringName in [&"normal", &"hover", &"disabled"]:
		theme.set_stylebox(state, TOGGLE, off)
	for state: StringName in [&"pressed", &"hover_pressed"]:
		theme.set_stylebox(state, TOGGLE, on)
	theme.set_stylebox(&"focus", TOGGLE, StyleBoxEmpty.new())
	AbyssTextStyle.new(13, AbyssFonts.Weight.BOLD, AbyssColors.ON_SURFACE_DIM).apply_to(theme, TOGGLE)
	theme.set_color(&"font_hover_color", TOGGLE, AbyssColors.ON_SURFACE_DIM)
	for state: StringName in [&"font_pressed_color", &"font_hover_pressed_color"]:
		theme.set_color(state, TOGGLE, AbyssColors.BIOLUM_CYAN)

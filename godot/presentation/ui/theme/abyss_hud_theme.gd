class_name AbyssHudTheme
## The panels laid over the 3D world, such as the frame counter, which the
## Flutter game had no need of: a translucent abyss panel faintly rimmed in
## cyan, so that the world shows through, and the compact text styles of
## the figures it shows. Its buttons are the Segment ones.

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
	}
	for name in styles:
		AbyssTextTheme.add_label(theme, name, styles[name])

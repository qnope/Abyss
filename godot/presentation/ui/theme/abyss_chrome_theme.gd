class_name AbyssChromeTheme
## The chrome around a screen, ported from the snackBarTheme and the
## navigationBarTheme of lib/presentation/theme/abyss_theme.dart: the snack
## bar, a bright rounded panel floating over the screen (SnackBarPanel and
## its text, SnackBarLabel), and the navigation bar, a dark veil
## (NavigationBarPanel) of destinations (NavigationItem, a toggle button in
## a ButtonGroup) each an icon over its name, the selected one lit in cyan
## on a tint.
##
## A destination's icon above its name is a node setting, not a theme one:
## [code]icon_alignment = HORIZONTAL_ALIGNMENT_CENTER[/code] and
## [code]vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP[/code]. Flutter
## writes the selected name in 600 and the others in the platform's regular
## weight; a Button has one font, so every name is in 600.

const CYAN := AbyssColors.BIOLUM_CYAN
const DIM := AbyssColors.ON_SURFACE_DIM
## Height of the navigation bar, Material 3's.
const BAR_HEIGHT := 80.0
const ITEM_RADIUS := 16
const ICON_SIZE := 24

const SNACK_BAR := &"SnackBarPanel"
const SNACK_LABEL := &"SnackBarLabel"
const BAR := &"NavigationBarPanel"
const ITEM := &"NavigationItem"


## Adds the snack bar and the navigation bar to [param theme].
static func apply(theme: Theme) -> void:
	theme.set_type_variation(SNACK_BAR, &"PanelContainer")
	var snack := AbyssBox.flat(AbyssColors.SURFACE_BRIGHT, 12, Vector2i(16, 14))
	theme.set_stylebox(&"panel", SNACK_BAR, AbyssBox.lifted(snack, Color.BLACK, 6))
	var body := AbyssTextTheme.roles()[&"BodyMedium"]
	AbyssTextTheme.add_label(theme, SNACK_LABEL, body)
	theme.set_type_variation(BAR, &"PanelContainer")
	var bar := AbyssBox.flat(Color(AbyssColors.ABYSS_BLACK, 0.95), 0, Vector2i(8, 12))
	theme.set_stylebox(&"panel", BAR, bar)
	_item(theme)


static func _item(theme: Theme) -> void:
	theme.set_type_variation(ITEM, &"Button")
	var off := AbyssBox.flat(Color.TRANSPARENT, ITEM_RADIUS, Vector2i(4, 4))
	var on := AbyssBox.flat(Color(CYAN, 0.15), ITEM_RADIUS, Vector2i(4, 4))
	for state: StringName in [&"normal", &"hover", &"disabled"]:
		theme.set_stylebox(state, ITEM, off)
	for state: StringName in [&"pressed", &"hover_pressed"]:
		theme.set_stylebox(state, ITEM, on)
	theme.set_stylebox(&"focus", ITEM, StyleBoxEmpty.new())
	AbyssTextStyle.new(12, AbyssFonts.Weight.SEMI_BOLD, DIM).apply_to(theme, ITEM)
	for state: StringName in [&"pressed", &"hover_pressed"]:
		theme.set_color("font_%s_color" % state, ITEM, CYAN)
		theme.set_color("icon_%s_color" % state, ITEM, CYAN)
	theme.set_color(&"font_hover_color", ITEM, DIM)
	theme.set_color(&"icon_normal_color", ITEM, DIM)
	theme.set_color(&"icon_hover_color", ITEM, DIM)
	theme.set_constant(&"icon_max_width", ITEM, ICON_SIZE)
	theme.set_constant(&"h_separation", ITEM, 4)

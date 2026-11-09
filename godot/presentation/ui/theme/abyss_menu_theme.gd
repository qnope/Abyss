class_name AbyssMenuTheme
## Styles of the full-screen menus drawn above the abyss backdrop, ported
## from lib/presentation/theme/abyss_menu_theme.dart: the glowing game
## title, the large menu buttons and the footnotes.
##
## Godot draws a text's shadow and outline without blur: a Flutter shadow
## blurred by b becomes a hard halo b / 2 wide at a third of its opacity,
## about what the blur leaves over that width. The title's two shadows
## become its outline (the tight one) and its shadow (the wide one). A
## StyleBoxFlat has no gradient, so the primary button is filled with the
## middle of Flutter's cyan gradient. The buttons take Material 3's
## overlays, where Flutter's ink well uses its own close ones.

const CYAN := AbyssColors.BIOLUM_CYAN
## Share of a blurred shadow's opacity its hard halo keeps.
const GLOW_SHARE := 1.0 / 3.0
const TITLE_SPACING := 10.0
const SUBTITLE_SPACING := 3.0
const BUTTON_RADIUS := 12
const BUTTON_MIN_HEIGHT := 56.0
const BUTTON_GAP := 12.0
const BUTTON_PADDING := Vector2i(16, 10)
## The middle of the cyan gradient of a primary button.
const PRIMARY_FILL := (AbyssColors.BIOLUM_CYAN_LIGHT + AbyssColors.BIOLUM_CYAN_DEEP) / 2.0
## Text drawn on the glowing fill of a primary button.
const PRIMARY_INK := AbyssColors.DEEP_NAVY
## A discreet icon in a corner of a menu, readable over the art.
const CORNER_ICON := AbyssColors.ABYSS_MIST


## Adds the menu's texts and buttons to [param theme].
static func apply(theme: Theme) -> void:
	const B := AbyssFonts.Weight.BOLD
	const D := AbyssFonts.Weight.DEFAULT
	const BLACK := AbyssColors.ABYSS_BLACK
	var title := AbyssTextStyle.new(60, B, CYAN, TITLE_SPACING)
	_add_glowing(theme, &"HeroTitle", title, Color(CYAN, 0.45), 40)
	theme.set_color(&"font_outline_color", &"HeroTitle", _halo(Color(CYAN, 0.8)))
	theme.set_constant(&"outline_size", &"HeroTitle", 8)
	var mist := AbyssColors.ABYSS_MIST
	var subtitle := AbyssTextStyle.new(15, AbyssFonts.Weight.MEDIUM, mist, SUBTITLE_SPACING)
	_add_glowing(theme, &"HeroSubtitle", subtitle, Color(BLACK, 0.8), 6)
	var dim := AbyssColors.ON_SURFACE_DIM
	AbyssTextTheme.add_label(theme, &"MenuButtonSubtitle", AbyssTextStyle.new(13, D, dim))
	var on_fill := Color(PRIMARY_INK, 0.75)
	AbyssTextTheme.add_label(theme, &"MenuPrimarySubtitle", AbyssTextStyle.new(13, D, on_fill))
	# Flutter's footnote is 12.5 high; Godot's sizes are whole pixels.
	var footnote := AbyssTextStyle.new(13, D, dim)
	_add_glowing(theme, &"Footnote", footnote, Color(BLACK, 0.9), 4)
	# The badge takes the ink of the button it sits on.
	theme.set_type_variation(&"BadgeLabel", &"Label")
	theme.set_font(&"font", &"BadgeLabel", AbyssFonts.of(B))
	theme.set_font_size(&"font_size", &"BadgeLabel", 14)
	var primary := AbyssButtonLook.new(
		PRIMARY_FILL, PRIMARY_INK, BUTTON_RADIUS, BUTTON_PADDING, PRIMARY_FILL, PRIMARY_INK
	)
	_add_button(theme, &"MenuPrimaryButton", primary)
	for state: StringName in [&"normal", &"hover", &"pressed"]:
		var box := theme.get_stylebox(state, &"MenuPrimaryButton") as StyleBoxFlat
		theme.set_stylebox(state, &"MenuPrimaryButton", AbyssBox.glowing(box, Color(CYAN, 0.5), 24))
	var glass := Color(AbyssColors.ABYSS_BLACK, 0.6)
	var outlined := AbyssButtonLook.new(
		glass, CYAN, BUTTON_RADIUS, BUTTON_PADDING, glass, CYAN, Color(CYAN, 0.9), 1.5
	)
	_add_button(theme, &"MenuOutlinedButton", outlined)


## Adds [param style] as the Label variation [param name], under a
## shadow of [param glow] blurred by [param blur].
static func _add_glowing(
	theme: Theme, name: StringName, style: AbyssTextStyle, glow: Color, blur: int
) -> void:
	AbyssTextTheme.add_label(theme, name, style)
	theme.set_color(&"font_shadow_color", name, _halo(glow))
	theme.set_constant(&"shadow_offset_x", name, 0)
	theme.set_constant(&"shadow_offset_y", name, 0)
	theme.set_constant(&"shadow_outline_size", name, roundi(blur / 2.0))


## The hard halo standing for a blurred shadow of [param glow].
static func _halo(glow: Color) -> Color:
	return Color(glow, glow.a * GLOW_SHARE)


## Adds [param look] as the Button variation [param name], its label in
## large spaced capitals.
static func _add_button(theme: Theme, name: StringName, look: AbyssButtonLook) -> void:
	look.apply_to(theme, name)
	theme.set_font(&"font", name, AbyssFonts.of(AbyssFonts.Weight.BOLD, 3))
	theme.set_font_size(&"font_size", name, 20)

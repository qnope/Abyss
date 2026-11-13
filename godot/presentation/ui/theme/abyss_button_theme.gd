class_name AbyssButtonTheme
## The buttons of lib/presentation/theme/abyss_button_theme.dart. The
## filled ElevatedButton, the game's main action, is the plain Button; the
## others are its variations: OutlinedButton, TextButton and
## OverMapButton. Every label reads in LabelLarge, as Flutter's buttons.
##
## Not ported: Flutter's minimum button size (64 × 40), which Godot sets
## per node (custom_minimum_size), and the press ripple, drawn as the
## pressed overlay.

## Flutter's disabled ink for a button that sets none: onSurface at 38 %.
const DISABLED_INK := Color(AbyssColors.ON_SURFACE, 0.38)
## The variation of a button that floats over the map.
const OVER_MAP := &"OverMapButton"


## Adds the buttons to [param theme].
static func apply(theme: Theme) -> void:
	var label := AbyssTextTheme.button_label()
	theme.set_font(&"font", &"Button", label.font())
	theme.set_font_size(&"font_size", &"Button", label.size)
	filled().apply_to(theme, &"Button")
	outlined().apply_to(theme, &"OutlinedButton")
	text().apply_to(theme, &"TextButton")
	over_map().apply_to(theme, OVER_MAP)


## Glowing cyan fill, dark ink; a cyan shadow rises as it is pressed.
static func filled() -> AbyssButtonLook:
	return AbyssButtonLook.new(
		AbyssColors.BIOLUM_CYAN, AbyssColors.ABYSS_BLACK, 12, Vector2i(24, 14),
		AbyssColors.DISABLED, AbyssColors.ON_SURFACE_DIM,
		Color.TRANSPARENT, 0.0, Color(AbyssColors.BIOLUM_CYAN, 0.4), true
	)


## Cyan ink in a cyan rim, on nothing.
static func outlined() -> AbyssButtonLook:
	return AbyssButtonLook.new(
		Color.TRANSPARENT, AbyssColors.BIOLUM_CYAN, 12, Vector2i(24, 14),
		Color.TRANSPARENT, DISABLED_INK, AbyssColors.BIOLUM_CYAN, 1.5
	)


## Teal ink alone, for a minor action.
static func text() -> AbyssButtonLook:
	return AbyssButtonLook.new(
		Color.TRANSPARENT, AbyssColors.BIOLUM_TEAL, 8, Vector2i(16, 8),
		Color.TRANSPARENT, DISABLED_INK
	)


## An outlined button lying over the map, on deep water so it reads over
## any cell. Disabled, it loses the water, as in Flutter, whose style sets
## no disabled background.
static func over_map() -> AbyssButtonLook:
	var water := Color(AbyssColors.DEEP_NAVY, 0.85)
	return AbyssButtonLook.new(
		water, AbyssColors.BIOLUM_CYAN, 12, Vector2i(18, 10),
		Color.TRANSPARENT, DISABLED_INK, AbyssColors.BIOLUM_CYAN, 1.5
	)

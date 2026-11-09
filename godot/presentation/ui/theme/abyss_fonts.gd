class_name AbyssFonts
## The game's fonts: Rajdhani for every title, label and button, as in
## Flutter, and the engine's default font where Flutter writes in the
## platform's own (bodies, dialog titles), since the game ships no Roboto.

## The weights of Rajdhani, and DEFAULT for the engine's default font at
## its own weight, which stands for Flutter's platform font at any weight.
enum Weight { DEFAULT = 0, MEDIUM = 500, SEMI_BOLD = 600, BOLD = 700 }

const MEDIUM := preload("res://assets/fonts/rajdhani/Rajdhani-Medium.ttf")
const SEMI_BOLD := preload("res://assets/fonts/rajdhani/Rajdhani-SemiBold.ttf")
const BOLD := preload("res://assets/fonts/rajdhani/Rajdhani-Bold.ttf")


## The font of [param weight], its letters spaced by [param letter_spacing]
## pixels, as Flutter's letterSpacing. Godot spaces glyphs by whole pixels
## only, so the spacing is rounded: 1.5 gives 2, 1.2 gives 1.
static func of(weight: Weight, letter_spacing := 0.0) -> Font:
	var font := _file(weight)
	var spacing := roundi(letter_spacing)
	if spacing == 0:
		return font
	var spaced := FontVariation.new()
	spaced.base_font = font
	spaced.spacing_glyph = spacing
	return spaced


static func _file(weight: Weight) -> Font:
	match weight:
		Weight.MEDIUM:
			return MEDIUM
		Weight.SEMI_BOLD:
			return SEMI_BOLD
		Weight.BOLD:
			return BOLD
	return ThemeDB.fallback_font

class_name AbyssColors
## The game's palette, ported from lib/presentation/theme/abyss_colors.dart:
## same names, same values. Color("rrggbbaa") puts the alpha last, where
## Dart's 0xAARRGGBB puts it first. tests/palette_test.gd checks each one
## against the Dart source.

# Deep sea backgrounds
const ABYSS_BLACK := Color("0a0e1a")
const DEEP_NAVY := Color("0d1b2a")
const OCEAN_FLOOR := Color("132238")
const TRENCH := Color("1a2d47")

# Bioluminescent glows
const BIOLUM_CYAN := Color("00e5ff")
const BIOLUM_BLUE := Color("448aff")
const BIOLUM_TEAL := Color("1de9b6")
const BIOLUM_PURPLE := Color("b388ff")
const BIOLUM_PINK := Color("ff80ab")

## Ends of the glowing cyan gradient of a primary menu button.
const BIOLUM_CYAN_LIGHT := Color("6ff4ff")
const BIOLUM_CYAN_DEEP := Color("00c2de")

## Pale blue of light filtering through the water, for menu subtitles.
const ABYSS_MIST := Color("bde6f5")

## Daylight falling from the surface, for the light rays.
const DAYLIGHT := Color("ffffff")

# Resource colors
const ALGAE_GREEN := Color("69f0ae")
const CORAL_PINK := Color("ff6e91")
const ORE_BLUE := Color("42a5f5")
const ENERGY_YELLOW := Color("ffd740")
const PEARL_WHITE := Color("e0f7fa")

# Surfaces
const SURFACE_LIGHT := Color("1b3150")
const SURFACE_DIM := Color("152640")
const SURFACE_BRIGHT := Color("24405e")

# Terrain
const PLAIN_BLUE := Color("42a5f566")

## Opacity of the [constant ABYSS_BLACK] fog over the cells not yet seen.
const FOG_OPACITY := 0.7

# Functional
const SUCCESS := Color("69f0ae")
const WARNING := Color("ffd740")
const ERROR := Color("ff5252")
const ON_SURFACE := Color("cae5ff")
const ON_SURFACE_DIM := Color("7b9cc0")
const DISABLED := Color("3a5070")

## Opacity of a faded unavailable illustration, drawn in greyscale.
const UNAVAILABLE_OPACITY := 0.85


## [param color] faded as an unavailable item (unbuilt, locked).
static func dimmed(color: Color) -> Color:
	return Color(color, color.a * 0.5)

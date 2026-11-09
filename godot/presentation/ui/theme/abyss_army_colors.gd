class_name AbyssArmyColors
## Colours of the army's parade ground, ported from
## lib/presentation/theme/abyss_army_colors.dart: the hue of each squad,
## then the banner, the arriving recruit, the crest, the drill pads and
## the depot.

# The hue of a squad, one per UnitType, named after it: the ring on its
# pad, its banner and plaque.
const SCOUT := AbyssColors.BIOLUM_BLUE
const HARPOONIST := Color("ff7a33")
const GUARDIAN := Color("b0bec5")
const DOME_BREAKER := Color("ff9100")
const ABYSS_ADMIRAL := AbyssColors.BIOLUM_PURPLE
const SABOTEUR := AbyssColors.ALGAE_GREEN

# The banner of a squad: the finial and the crossbar of its pole, the
# dark edge of its parts, its shadow on the deck, the sheen on its
# pennant, and how faint it stands while the unit is locked.
const FINIAL := AbyssColors.ENERGY_YELLOW
const CROSSBAR := Color("8fa9c6")
const BANNER_EDGE := AbyssColors.ABYSS_BLACK
const BANNER_SHADOW := Color("02060d99")
const PENNANT_SHEEN := Color("ffffff0f")
const LOCKED_BANNER_OPACITY := 0.45

## Opacity of the ghost of a locked unit.
const GHOST_OPACITY := 0.7

# A recruit arriving: the glowing column it falls in, the bubbles rising
# through it, the ring it lands with.
const RECRUIT_COLUMN := AbyssColors.BIOLUM_CYAN
const RECRUIT_BUBBLE := AbyssColors.ABYSS_MIST
const LANDING_RING := AbyssColors.BIOLUM_CYAN_LIGHT

# The crest: a trident in a ring painted on a deck in the middle.
const CREST_LIGHT := AbyssColors.BIOLUM_CYAN
const CREST_SHEEN := Color("e0ffff")
const CREST_SHADOW := Color("02060d")

# The boot scuffs on a drill pad.
const SCUFF := Color("1a2b44")

# The crates of the depot: wood, steel and dark wood, their tops, their
# edges and straps, and the paint marked on them.
const CRATE_WOOD := Color("5d4037")
const CRATE_WOOD_TOP := Color("8d6e63")
const CRATE_STEEL := Color("455a64")
const CRATE_STEEL_TOP := Color("78909c")
const CRATE_DARK := Color("4e342e")
const CRATE_DARK_TOP := Color("795548")
const CRATE_EDGE := AbyssColors.ABYSS_BLACK
const CRATE_STRAP := Color("2e1a12")
const MARK_ORANGE := Color("ff9100")
const MARK_YELLOW := AbyssColors.ENERGY_YELLOW

# The harpoon rack and the lamp post of the depot.
const HARPOON_SHAFT := Color("3a2210")
const HARPOON_TIP := Color("b0bec5")
const RACK_BAR := Color("5d4037")
const POLE_METAL: Array[Color] = [Color("cfd8dc"), Color("78909c"), Color("37474f")]
const LAMP_GLASS := Color("e0ffff")
const LAMP_FRAME := Color("37474f")


## The pennant of a squad's banner: its [param hue] darkened towards the
## abyss.
static func pennant(hue: Color) -> Color:
	return hue.lerp(AbyssColors.ABYSS_BLACK, 0.55)

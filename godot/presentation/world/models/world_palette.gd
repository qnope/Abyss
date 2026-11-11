class_name WorldPalette
extends RefCounted
## The colours of the world's stand-ins and of the marks over the base: one
## per building, picked apart so that the eleven read at a glance, from the
## interface's own palette (the Flutter building colours) where they did not
## clash. The interface's BuildingColors repeats the buildings' ones and a
## test in app/ holds the two together: this layer never reads the interface.

const _BUILDINGS: Dictionary[BuildingType.Value, Color] = {
	BuildingType.Value.HEADQUARTERS: Color("b388ff"),
	BuildingType.Value.ALGAE_FARM: Color("69f0ae"),
	BuildingType.Value.CORAL_MINE: Color("ff6e91"),
	BuildingType.Value.CORAL_CITADEL: Color("ffccbc"),
	BuildingType.Value.ORE_EXTRACTOR: Color("42a5f5"),
	BuildingType.Value.SOLAR_PANEL: Color("ffd740"),
	BuildingType.Value.LABORATORY: Color("1de9b6"),
	BuildingType.Value.BARRACKS: Color("e040fb"),
	BuildingType.Value.DESCENT_MODULE: Color("b0bec5"),
	BuildingType.Value.PRESSURE_CAPSULE: Color("00e5ff"),
	BuildingType.Value.VOLCANIC_KERNEL: Color("ff6d00"),
}

## The units' stand-ins, one colour each (the interface's `UnitColors`
## repeats them).
const _UNITS: Dictionary[UnitType.Value, Color] = {
	UnitType.Value.SCOUT: Color("448aff"),
	UnitType.Value.HARPOONIST: Color("ff5252"),
	UnitType.Value.GUARDIAN: Color("b0bec5"),
	UnitType.Value.DOME_BREAKER: Color("ff9100"),
	UnitType.Value.ABYSS_ADMIRAL: Color("b388ff"),
	UnitType.Value.SABOTEUR: Color("69f0ae"),
}

## A degraded building, greyed and dull.
const DEGRADED := Color("78909c")
## The ghost of a locked unit: the grey, and how much of it shows.
const GHOST_OPACITY := 0.5
## How much of its colour a stand-in glows with, to read in the dark water.
const GLOW := 0.22

## The marks over a pad: a building that can rise, a plot that can be built
## on, a plot held back, a building that works badly.
const UPGRADE := Color("69f0ae")
const BUILD := Color("00e5ff")
const LOCKED := Color("cfd8dc")
const WARNING := Color("ffab40")
## The parade ground: its deck, the plot of a barracks to build, the crest in
## the middle, and how faint an empty squad's count is written.
const GROUND := Color("2b3a4d")
const PLOT := Color("56657a")
const CREST := Color("00e5ff")
const EMPTY_SQUAD := 0.55
## The guide's ring around the pad or the cell it points at (the interface's
## cyan, which a test in app/ holds together with this one).
const GUIDE := Color("00e5ff")
## The level written over a building, and its outline.
const LEVEL := Color("ffffff")
const LEVEL_OUTLINE := Color("0a0e1a")


## The colour of the building [param type].
static func of(type: BuildingType.Value) -> Color:
	return _BUILDINGS[type]


## The colour of the unit [param type].
static func unit(type: UnitType.Value) -> Color:
	return _UNITS[type]

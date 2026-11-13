class_name LightMoods
extends RefCounted
## The light of each place, from the palette up to the shaders: the base's,
## the one that was reviewed first, and one for each level of the map, after
## the mood of the interface's backdrops. The surface is the bright teal of
## the shallows, the depths a twilight blue under a colder light, the core a
## dark red and orange, lit by the volcano's heat. Every mood keeps the key
## light bright enough that the models' signature colours still tell the
## buildings and the contents apart.

const BASE_KEY := Color("fff3e2")
const BASE_SKY: Array[Color] = [Color(0.16, 0.42, 0.52), Color(0.05, 0.19, 0.28), Color(0.008, 0.035, 0.07)]
const BASE_FOG := Color("082a3c")

const SURFACE_KEY := Color("f4fff0")
const SURFACE_SKY: Array[Color] = [Color(0.2, 0.55, 0.55), Color(0.07, 0.28, 0.34), Color(0.012, 0.07, 0.09)]
const SURFACE_FOG := Color("0a3c48")

const DEPTHS_KEY := Color("d0dcff")
const DEPTHS_SKY: Array[Color] = [Color(0.16, 0.25, 0.44), Color(0.05, 0.1, 0.27), Color(0.012, 0.02, 0.08)]
const DEPTHS_FOG := Color("0c1a48")

const CORE_KEY := Color("ffb48a")
const CORE_SKY: Array[Color] = [Color(0.42, 0.16, 0.09), Color(0.22, 0.07, 0.05), Color(0.1, 0.025, 0.015)]
const CORE_FOG := Color("34100a")


## The base: daylight after metres of water, over a teal sea.
static func base() -> LightMood:
	return LightMood.new(BASE_KEY, 2.0, 2.4, BASE_SKY, BASE_FOG, 0.006)


## Level 1, the shallows: the sun nearer, the water clearer and greener.
static func surface() -> LightMood:
	return LightMood.new(SURFACE_KEY, 2.2, 2.6, SURFACE_SKY, SURFACE_FOG, 0.005)


## Level 2, the twilight: a cold light from far above over a deep blue sea.
static func depths() -> LightMood:
	return LightMood.new(DEPTHS_KEY, 2.0, 2.4, DEPTHS_SKY, DEPTHS_FOG, 0.008)


## Level 3, the core: no sun left, the red and orange glow of the magma.
static func core() -> LightMood:
	return LightMood.new(CORE_KEY, 2.3, 2.9, CORE_SKY, CORE_FOG, 0.008)


## The mood of [param level] (1 and up): the deepest serves the levels below it.
static func of_level(level: int) -> LightMood:
	match MapScenery.index_of(level):
		0:
			return surface()
		1:
			return depths()
	return core()

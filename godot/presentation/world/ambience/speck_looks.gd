class_name SpeckLooks
extends RefCounted
## The specks of each level of the map: the shallows' marine snow, falling
## slowly through the light; the depths' bubbles, rising from the floor, a few
## and big; the core's ash and embers, warm specks drifting up on the heat.
## Few of them (the web draws each as a quad on the processor): the colours
## are soft and mostly transparent, so that none of them reads as a unit.

const SNOW := Color(0.85, 1.0, 0.95, 0.6)
const BUBBLES := Color(0.7, 0.85, 1.0, 0.65)
const ASH := Color(1.0, 0.6, 0.32, 0.75)


## Level 1: marine snow, a few more than the base's, bigger for the far view.
static func surface() -> SpeckLook:
	return SpeckLook.new(SNOW, 140, 0.28, 14.0, -0.1, Vector2(0.05, 0.25), 5.0)


## Level 2: bubbles rising from the floor.
static func depths() -> SpeckLook:
	return SpeckLook.new(BUBBLES, 70, 0.36, 9.0, 0.12, Vector2(0.2, 0.4), 0.6)


## Level 3: ash and embers drifting up and sideways.
static func core() -> SpeckLook:
	return SpeckLook.new(ASH, 110, 0.26, 12.0, 0.06, Vector2(0.1, 0.35), 4.0)


## The specks of [param level] (1 and up): the deepest serves the levels below it.
static func of_level(level: int) -> SpeckLook:
	match MapScenery.index_of(level):
		0:
			return surface()
		1:
			return depths()
	return core()

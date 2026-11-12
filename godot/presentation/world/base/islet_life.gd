class_name IsletLife
extends Node3D
## The islet's own life, over the marine snow and the bubbles of every
## building: more bubbles round the buildings that carry a lamp, a turtle that
## swims round the island and a school of small fish drifting round it. Cheap
## on purpose (a few dozen particles, a model of 1 200 triangles, one draw
## call of fish): the web and the phones stay fluid; it stops with the
## particles of the quality panel.

const TURTLE := preload("res://assets/models/map_turtle.glb")
## The buildings whose lamp lights the water round them: the headquarters'
## beacon, the citadel's heart, the descent module's and the capsule's
## beacons, the kernel's flame.
const LAMPS: Array[StringName] = [
	&"Headquarters", &"CoralCitadel", &"DescentModule", &"PressureCapsule", &"VolcanicKernel",
]
const LAMP_BUBBLES := 30
## The turtle's lap in seconds, its distance from the island's middle and
## how high it swims.
const LAP := 90.0
const REACH := 12.5
const DEPTH := -0.4

var lamps := RisingBubbles.new(LAMP_BUBBLES)
var turtle := CreatureLap.new()
var fish := FishSchool.new()
var _running := true
var _lit := false


func _init() -> void:
	name = &"Life"
	for part: Node3D in [lamps, turtle, fish]:
		add_child(part)
	turtle.swim(TURTLE, Vector2.ONE * REACH, DEPTH, LAP)
	_bubble()


## Lets the bubbles rise round the lamps of the buildings of [param buildings]
## that stand and work (a degraded one is still), on their [param pads].
func show_lamps(pads: BasePads, buildings: BaseBuildings) -> void:
	var sources := PackedVector3Array()
	for name_ in LAMPS:
		if buildings.building(name_) != null and not buildings.is_degraded(name_):
			sources.append(pads.origin_of(name_))
	lamps.rise_from(sources)
	_lit = not sources.is_empty()
	_bubble()


## Shows the life and lets it go on, or hides it and stops computing it.
func set_running(running: bool) -> void:
	visible = running
	process_mode = Node.PROCESS_MODE_INHERIT if running else Node.PROCESS_MODE_DISABLED
	_running = running
	_bubble()


## The bubbles rise while the life runs and there is a lamp to light them.
func _bubble() -> void:
	lamps.set_running(_running and _lit)

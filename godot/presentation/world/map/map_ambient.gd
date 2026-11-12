class_name MapAmbient
extends Node3D
## The creature of the level (a turtle, a jelly, a ray) that swims round the
## slab of the map, a lap every [constant LAP] seconds, turned along its way,
## playing its `swim` loop. It is scenery: it never takes a tap.

## Seconds a lap takes.
const LAP := 80.0
## How far beyond the slab's edge it swims, and how high above the floor.
const ROOM := 1.5
const HEIGHT := 0.9

var creature: Node3D
var _animator: ModelAnimator
var _angle := 0.0
var _radii := Vector2.ONE


func _process(delta: float) -> void:
	advance(delta)


## Sets the creature of [param level] swimming round a map of [param width] by
## [param height] cells, in place of the one before.
func show_level(level: int, width: int, height: int) -> void:
	if creature != null:
		creature.free()
	creature = MapScenery.CREATURES[MapScenery.index_of(level)].instantiate() as Node3D
	add_child(creature)
	_animator = ModelAnimator.new(creature)
	_animator.play(&"swim")
	_radii = Vector2(width, height) / 2.0 + Vector2.ONE * ROOM
	_place()


## Lets [param seconds] pass: the creature swims on.
func advance(seconds: float) -> void:
	_angle = fmod(_angle + TAU * seconds / LAP, TAU)
	_place()


func _place() -> void:
	if creature == null:
		return
	creature.position = Vector3(_radii.x * cos(_angle), HEIGHT, _radii.y * sin(_angle))
	var heading := Vector2(-_radii.x * sin(_angle), _radii.y * cos(_angle))
	# The creature is built facing -Z.
	creature.rotation.y = atan2(-heading.x, -heading.y)

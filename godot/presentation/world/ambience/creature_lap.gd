class_name CreatureLap
extends Node3D
## A creature that swims round a place, an ellipse of [param radii] metres
## in the place's plane, turned along its way and playing its `swim` loop: the
## turtle, jelly or ray of the map's slab, the one that passes the base. It is
## scenery: it never takes a tap. Asked for the creature it already has (the
## map is drawn again on each action of the player), it keeps it: a new one
## would start its stroke again under the player's eyes.

var creature: Node3D
var _scene: PackedScene
var _animator: ModelAnimator
var _angle := 0.0
var _radii := Vector2.ONE
var _height := 0.0
var _lap := 1.0


func _process(delta: float) -> void:
	advance(delta)


## Sets the creature of [param scene] swimming [param height] metres up,
## round an ellipse of [param radii], a lap every [param lap] seconds, from
## where the lap is. The creature already swimming swims on, its stroke going
## on; another takes its place.
func swim(scene: PackedScene, radii: Vector2, height: float, lap: float) -> void:
	if scene != _scene:
		_scene = scene
		if creature != null:
			creature.free()
		creature = scene.instantiate() as Node3D
		add_child(creature)
		_animator = ModelAnimator.new(creature)
		_animator.play(&"swim")
	_radii = radii
	_height = height
	_lap = lap
	_place()


## Lets [param seconds] pass: the creature swims on.
func advance(seconds: float) -> void:
	_angle = fmod(_angle + TAU * seconds / _lap, TAU)
	_place()


func _place() -> void:
	if creature == null:
		return
	creature.position = Vector3(_radii.x * cos(_angle), _height, _radii.y * sin(_angle))
	var heading := Vector2(-_radii.x * sin(_angle), _radii.y * cos(_angle))
	# The creatures are built facing -Z.
	creature.rotation.y = atan2(-heading.x, -heading.y)

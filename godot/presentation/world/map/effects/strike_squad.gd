class_name StrikeSquad
extends Node3D
## The army that attacks, on the map: the figures of its units ([StrikeLead.figures],
## the lead's first) standing close together on the floor, facing what they
## attack, with the army's count over them ("×N", Flutter's badge). Its origin
## is the floor under the middle of the group. It plays an animation on every
## figure, and shrinks away at the end.

## How closely the figures stand (the parade's slots, shrunk), and how high the
## count floats.
const SLOT_SCALE := 0.4
const COUNT_HEIGHT := 1.1
const FONT_SIZE := 56
const OUTLINE := 14
const PIXEL_SIZE := 0.007

## The figures standing.
var figures: Array[Node3D] = []
## The "×N" over them.
var badge := Label3D.new()
var _animators: Array[ModelAnimator] = []


## The army [param sent]: how many of each unit it holds.
func _init(sent: Dictionary[UnitType.Value, int]) -> void:
	name = &"Squad"
	var types := StrikeLead.figures(sent)
	for index in types.size():
		var figure := WorldModels.unit(types[index])
		figure.rotation = Vector3.ZERO
		var slot := ParadeLayout.SLOTS[index] * SLOT_SCALE
		figure.position = Vector3(slot.x, 0.0, slot.y)
		add_child(figure)
		figures.append(figure)
		var animator := WorldModels.animator(figure)
		if animator != null:
			_animators.append(animator)
	var total := 0
	for count: int in sent.values():
		total += count
	badge.name = &"Count"
	badge.text = "×%d" % total
	badge.font_size = FONT_SIZE
	badge.outline_size = OUTLINE
	badge.pixel_size = PIXEL_SIZE
	badge.modulate = MapPalette.COUNT
	badge.outline_modulate = MapPalette.COUNT_OUTLINE
	badge.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	badge.no_depth_test = true
	badge.render_priority = 2
	badge.shaded = false
	badge.position.y = COUNT_HEIGHT
	add_child(badge)


## Turns the army to face [param direction] on the floor (the figures face -Z).
func face(direction: Vector3) -> void:
	if Vector2(direction.x, direction.z).length() > 1e-4:
		rotation.y = atan2(-direction.x, -direction.z)


## Plays [param animation] on every figure that has it, so that it lasts
## [param seconds] (an animation of its own length when 0).
func play(animation: StringName, seconds := 0.0) -> void:
	for animator in _animators:
		var length := animator.length_of(animation)
		animator.play(animation, length / seconds if seconds > 0.0 and length > 0.0 else 1.0)


## Shrinks the army away as [param share] goes from 0 (there) to 1 (gone).
func vanish(share: float) -> void:
	scale = Vector3.ONE * maxf(1.0 - share, 0.001)
	badge.modulate.a = 1.0 - share

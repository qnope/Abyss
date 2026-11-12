class_name SiegeAttackers
extends Node3D
## The attackers of a siege on the map: [constant SiegeGeometry.ATTACKERS] figures
## made by the [MapSiege], each on a ring of the siege's colour on the floor.
## [method put] sets where each stands, facing the place; [method play] plays an
## animation on them all; [method vanish] shrinks them away.

## The radius of the ring under each, in metres, and how bright it is.
const RING_RADIUS := 0.4
const RING_OPACITY := 0.8

## The figures, in the order of [method SiegeGeometry.attacker_at].
var figures: Array[Node3D] = []
var _slots: Array[Node3D] = []
var _rings: Array[FloorMark] = []
var _colour: Color


func _init(siege: MapSiege) -> void:
	name = &"Attackers"
	_colour = siege.ring
	for index in SiegeGeometry.ATTACKERS:
		var figure: Node3D = siege.attacker.call()
		figure.rotation = Vector3.ZERO
		var slot := Node3D.new()
		slot.add_child(figure)
		add_child(slot)
		figures.append(figure)
		_slots.append(slot)
		var ring := FloorMark.new()
		ring.show_mark(RING_RADIUS, _colour, RING_OPACITY)
		add_child(ring)
		_rings.append(ring)


## Stands attacker [param index] at [param position_], turned to [param toward]
## (the figures face -Z).
func put(index: int, position_: Vector3, toward: Vector3) -> void:
	_slots[index].position = position_
	_rings[index].position = Vector3(position_.x, FloorMark.HEIGHT, position_.z)
	var way := toward - position_
	if Vector2(way.x, way.z).length() > 1e-4:
		_slots[index].rotation.y = atan2(-way.x, -way.z)


## Where attacker [param index] stands.
func where(index: int) -> Vector3:
	return _slots[index].position


## Plays [param animation] on every figure, so that it lasts [param seconds] (an
## animation of its own length when 0).
func play(animation: StringName, seconds := 0.0) -> void:
	for figure in figures:
		if figure is MonsterFigure:
			var monster: MonsterFigure = figure
			monster.play(animation, _speed(monster.length_of(animation), seconds))
		else:
			var animator := WorldModels.animator(figure)
			if animator != null:
				animator.play(animation, _speed(animator.length_of(animation), seconds))


## Shrinks the attackers away as [param share] goes from 0 (there) to 1 (gone).
func vanish(share: float) -> void:
	var left := maxf(1.0 - share, 0.001)
	for index in figures.size():
		_slots[index].scale = Vector3.ONE * left
		_rings[index].show_mark(RING_RADIUS * left, _colour, RING_OPACITY * left)


func _speed(length: float, seconds: float) -> float:
	return length / seconds if seconds > 0.0 and length > 0.0 else 1.0

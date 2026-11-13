class_name SpeckLook
extends RefCounted
## What drifts in the water of a place: how many specks, how big, their colour
## (alpha included), how long each lives, whether it falls or rises (a
## gravity along y, in m/s squared), how fast it sets off, and how high the
## cloud of them stands above the floor. A palette's ([SpeckLooks]).

var colour: Color
var amount: int
var size: float
var lifetime: float
var lift: float
var speed: Vector2
## The height of the box they drift in, from the floor.
var height: float


func _init(colour_: Color, amount_: int, size_: float, lifetime_: float, lift_: float,
		speed_: Vector2, height_: float) -> void:
	colour = colour_
	amount = amount_
	size = size_
	lifetime = lifetime_
	lift = lift_
	speed = speed_
	height = height_

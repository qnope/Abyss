class_name RisingBubbles
extends CPUParticles3D
## Bubbles rising from the base's buildings, a few at a time, swelling and
## fading as they go up. CPU particles, as the marine snow.

const AMOUNT := 36
const LIFETIME := 6.0
## How far around a building's centre bubbles leave from.
const SPREAD := 0.9
const SEED := 7
const COLOUR := Color(0.75, 0.95, 1.0, 0.7)


## [param count] bubbles are alive at a time: a place with more to say about
## it asks for more.
func _init(count := AMOUNT) -> void:
	amount = count
	lifetime = LIFETIME
	preprocess = LIFETIME
	randomness = 0.6
	emission_shape = EMISSION_SHAPE_POINTS
	direction = Vector3.UP
	spread = 12.0
	initial_velocity_min = 0.3
	initial_velocity_max = 0.6
	gravity = Vector3(0.0, 0.35, 0.0)
	scale_amount_min = 0.6
	scale_amount_max = 1.4
	scale_amount_curve = _swelling()
	color = COLOUR
	color_ramp = _fading()
	mesh = ParticleDot.quad(0.12, 0.15, 0.9)
	cast_shadow = SHADOW_CASTING_SETTING_OFF
	rise_from(PackedVector3Array([Vector3.ZERO]))


## Lets the bubbles leave from around each of [param sources], the
## buildings' centres in the base's space.
func rise_from(sources: PackedVector3Array) -> void:
	var random := RandomNumberGenerator.new()
	random.seed = SEED
	var points := PackedVector3Array()
	for source in sources:
		for index in 6:
			var angle := random.randf() * TAU
			var reach := random.randf_range(0.3, 1.0) * SPREAD
			points.append(source + Vector3(cos(angle) * reach, 0.2, sin(angle) * reach))
	emission_points = points


## Shows the bubbles or hides them, and stops computing them while hidden.
func set_running(running: bool) -> void:
	emitting = running
	visible = running


static func _swelling() -> Curve:
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 0.5))
	curve.add_point(Vector2(1.0, 1.0))
	return curve


static func _fading() -> Gradient:
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.15, 0.75, 1.0])
	ramp.colors = PackedColorArray([
		Color(1.0, 1.0, 1.0, 0.0), Color.WHITE, Color.WHITE, Color(1.0, 1.0, 1.0, 0.0),
	])
	return ramp

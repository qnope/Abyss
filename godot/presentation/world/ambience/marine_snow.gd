class_name MarineSnow
extends CPUParticles3D
## Marine snow: specks drifting down through the water around the base,
## already falling when the scene opens. CPU particles: a few hundred cost
## next to nothing on the processor, draw in one call, and behave the same
## on the web's Compatibility renderer and on the phones' Mobile one, with
## no particle shader to compile at startup.

const AMOUNT := 220
const LIFETIME := 16.0
## The box they drift in, around the island and above it.
const VOLUME := Vector3(17.0, 9.0, 17.0)
const CENTRE := Vector3(0.0, 4.0, 0.0)
const COLOUR := Color(0.78, 0.9, 1.0, 0.55)


func _init() -> void:
	amount = AMOUNT
	lifetime = LIFETIME
	preprocess = LIFETIME
	randomness = 1.0
	position = CENTRE
	emission_shape = EMISSION_SHAPE_BOX
	emission_box_extents = VOLUME
	direction = Vector3(1.0, -0.2, 0.0)
	spread = 180.0
	initial_velocity_min = 0.05
	initial_velocity_max = 0.25
	gravity = Vector3(0.0, -0.12, 0.0)
	damping_min = 0.02
	damping_max = 0.05
	scale_amount_min = 0.5
	scale_amount_max = 1.6
	color = COLOUR
	mesh = ParticleDot.quad(0.06, 1.0, 0.5)
	cast_shadow = SHADOW_CASTING_SETTING_OFF


## Shows the snow or hides it, and stops computing it while hidden.
func set_running(running: bool) -> void:
	emitting = running
	visible = running

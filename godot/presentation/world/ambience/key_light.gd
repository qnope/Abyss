class_name KeyLight
extends DirectionalLight3D
## The light filtering down from the surface: the scene's one directional
## light and its only shadows. Two cascades, unblended, are the cheapest
## that keep the deck's shadows sharp from the game's view to the farthest
## zoom; a third would cost a pass more of every caster each frame.

## The light's colour: daylight after metres of water.
const COLOUR := Color("fff3e2")
const ENERGY := 2.0
## From high over the upper left of the game's camera, as the models were
## reviewed in (tool/models/studio.gd).
const ANGLES := Vector3(-52.0, 15.0, 0.0)
## How far from the camera shadows are drawn: the island from the farthest
## view, and not a metre more of the sea.
const SHADOW_DISTANCE := 56.0


func _init() -> void:
	light_color = COLOUR
	light_energy = ENERGY
	rotation_degrees = ANGLES
	shadow_enabled = true
	shadow_blur = 1.0
	directional_shadow_mode = SHADOW_PARALLEL_2_SPLITS
	directional_shadow_split_1 = 0.45
	directional_shadow_blend_splits = false
	directional_shadow_max_distance = SHADOW_DISTANCE


## Turns the shadows on or off: the costliest part of the scene's lighting.
func set_shadows(enabled: bool) -> void:
	shadow_enabled = enabled

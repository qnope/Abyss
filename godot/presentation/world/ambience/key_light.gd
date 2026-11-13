class_name KeyLight
extends DirectionalLight3D
## The light filtering down from the surface: the scene's one directional
## light and its only shadows. Two cascades, unblended, are the cheapest
## that keep the deck's shadows sharp from the game's view to the farthest
## zoom; a third would cost a pass more of every caster each frame.

## From high over the upper left of the game's camera, as the models were
## reviewed in (tool/models/studio.gd).
const ANGLES := Vector3(-52.0, 15.0, 0.0)
## How far from the camera shadows are drawn: the island from the farthest
## view, and not a metre more of the sea.
const SHADOW_DISTANCE := 56.0


## The light of [param mood] (its colour and energy), the base's by default.
func _init(mood := LightMoods.base()) -> void:
	set_mood(mood)
	rotation_degrees = ANGLES
	shadow_enabled = true
	shadow_blur = 1.0
	directional_shadow_mode = SHADOW_PARALLEL_2_SPLITS
	directional_shadow_split_1 = 0.45
	directional_shadow_blend_splits = false
	directional_shadow_max_distance = SHADOW_DISTANCE


## Lights with the colour and the energy of [param mood].
func set_mood(mood: LightMood) -> void:
	light_color = mood.key_colour
	light_energy = mood.key_energy


## Turns the shadows on or off: the costliest part of the scene's lighting.
func set_shadows(enabled: bool) -> void:
	shadow_enabled = enabled

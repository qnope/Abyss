class_name LightMood
extends RefCounted
## How the water is lit in a place: the key light's colour and energy, the
## sky the ambient light comes from (its surface, horizon and abyss), the
## strength of that ambient light and the fog. The colours are a palette's
## ([LightMoods]); [UnderwaterEnvironment] and [KeyLight] wear a mood.

var key_colour: Color
var key_energy: float
var ambient_energy: float
## The sky's colours: overhead, at the horizon and under the deck.
var sky_surface: Color
var sky_horizon: Color
var sky_abyss: Color
var fog_colour: Color
var fog_density: float


func _init(key: Color, key_energy_: float, ambient_energy_: float, sky: Array[Color],
		fog: Color, fog_density_: float) -> void:
	key_colour = key
	key_energy = key_energy_
	ambient_energy = ambient_energy_
	sky_surface = sky[0]
	sky_horizon = sky[1]
	sky_abyss = sky[2]
	fog_colour = fog
	fog_density = fog_density_

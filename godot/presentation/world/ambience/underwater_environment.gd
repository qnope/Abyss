class_name UnderwaterEnvironment
extends WorldEnvironment
## The deep sea around the base: a gradient of water lit from the surface
## as sky and ambient light (deep_sea_sky.gdshader), a fog that thickens
## with distance and under the deck, so the island's spike sinks into the
## abyss, and glow on the lights only. Everything here runs on the web's
## Compatibility renderer as on the Mobile one; the glow there needs the
## HDR 2D buffer of project.godot.

const SKY_SHADER := preload("res://presentation/world/ambience/deep_sea_sky.gdshader")
## Godot's filmic curves (AgX, ACES) bleach a bright saturated light towards
## white: the citadel's pink heart and the gold lamps read pale. The linear
## curve keeps their hue, the glow carries their brightness.
const TONEMAPPER := Environment.TONE_MAPPER_LINEAR
const EXPOSURE := 1.1
const SATURATION := 1.12
const CONTRAST := 1.06
## Fog: how fast it thickens under FOG_FLOOR (its colour and its density with
## distance are the mood's, [LightMood]).
const FOG_FLOOR := -3.0
const FOG_DEPTH_DENSITY := 0.05
## The glow's spread: its weight at each blur level, the finest first.
const GLOW_LEVELS: Array[float] = [0.0, 1.0, 0.8, 0.5, 0.2, 0.0, 0.0]

var _sky_material := ShaderMaterial.new()


## The water lit by [param mood], the base's by default.
func _init(mood := LightMoods.base()) -> void:
	var water := Environment.new()
	water.background_mode = Environment.BG_SKY
	water.sky = _sky()
	water.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	water.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	water.tonemap_mode = TONEMAPPER
	water.tonemap_exposure = EXPOSURE
	water.adjustment_enabled = true
	water.adjustment_saturation = SATURATION
	water.adjustment_contrast = CONTRAST
	_fog(water)
	_glow(water)
	environment = water
	set_mood(mood)


## Lights the water with [param mood]: its sky and ambient light, its fog.
func set_mood(mood: LightMood) -> void:
	_sky_material.set_shader_parameter(&"surface_colour", mood.sky_surface)
	_sky_material.set_shader_parameter(&"horizon_colour", mood.sky_horizon)
	_sky_material.set_shader_parameter(&"abyss_colour", mood.sky_abyss)
	environment.ambient_light_energy = mood.ambient_energy
	environment.fog_light_color = mood.fog_colour
	environment.fog_density = mood.fog_density


## Turns the glow on or off: a few blurred passes over the whole screen.
func set_glow(enabled: bool) -> void:
	environment.glow_enabled = enabled


func _sky() -> Sky:
	_sky_material.shader = SKY_SHADER
	var sky := Sky.new()
	sky.sky_material = _sky_material
	sky.radiance_size = Sky.RADIANCE_SIZE_32
	return sky


static func _fog(water: Environment) -> void:
	water.fog_enabled = true
	water.fog_mode = Environment.FOG_MODE_EXPONENTIAL
	water.fog_sky_affect = 0.0
	water.fog_sun_scatter = 0.15
	water.fog_height = FOG_FLOOR
	water.fog_height_density = FOG_DEPTH_DENSITY


static func _glow(water: Environment) -> void:
	water.glow_enabled = true
	water.glow_normalized = false
	water.glow_intensity = 0.7
	water.glow_strength = 1.0
	water.glow_bloom = 0.0
	water.glow_hdr_threshold = 0.9
	water.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	for level in GLOW_LEVELS.size():
		water.set_glow_level(level, GLOW_LEVELS[level])

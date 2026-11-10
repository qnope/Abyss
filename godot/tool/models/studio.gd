extends Node3D
## The neutral studio a model is reviewed in: a key light with shadows, a cool
## fill, a dark blue background and a ground disc under the model.

const BACKGROUND := Color("0d1b2a")
const GROUND := Color("101c2c")


func _init(model: Node3D, bounds: AABB) -> void:
	add_child(_environment())
	add_child(_key_light(bounds))
	add_child(_fill_light())
	add_child(_ground(bounds))
	add_child(model)


func _environment() -> WorldEnvironment:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = BACKGROUND
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("5b7aa6")
	environment.ambient_light_energy = 0.5
	environment.tonemap_mode = Environment.TONE_MAPPER_AGX
	environment.glow_enabled = true
	environment.glow_intensity = 0.5
	environment.glow_bloom = 0.0
	environment.glow_hdr_threshold = 1.0
	environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	var world := WorldEnvironment.new()
	world.environment = environment
	return world


func _key_light(bounds: AABB) -> DirectionalLight3D:
	var light := DirectionalLight3D.new()
	light.light_color = Color("fff1dc")
	light.light_energy = 1.25
	light.shadow_enabled = true
	light.shadow_blur = 1.5
	light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	light.directional_shadow_max_distance = bounds.size.length() * 3.0
	light.rotation_degrees = Vector3(-55.0, -30.0, 0.0)
	return light


func _fill_light() -> DirectionalLight3D:
	var light := DirectionalLight3D.new()
	light.light_color = Color("7fb2ff")
	light.light_energy = 0.35
	light.rotation_degrees = Vector3(-20.0, 150.0, 0.0)
	return light


func _ground(bounds: AABB) -> MeshInstance3D:
	var disc := CylinderMesh.new()
	var radius := maxf(bounds.size.x, bounds.size.z) * 0.9
	disc.top_radius = radius
	disc.bottom_radius = radius
	disc.height = 0.02
	disc.radial_segments = 96
	var material := StandardMaterial3D.new()
	material.albedo_color = GROUND
	material.roughness = 1.0
	disc.material = material
	var ground := MeshInstance3D.new()
	ground.mesh = disc
	ground.position = Vector3(bounds.get_center().x, bounds.position.y - 0.011, bounds.get_center().z)
	return ground

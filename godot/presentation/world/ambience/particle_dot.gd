class_name ParticleDot
extends RefCounted
## The look of a speck in the water, shared by the marine snow and the
## bubbles: a camera-facing quad, unlit, its colour the particle's, its
## shape a soft radial gradient made in code. One small texture, no light,
## no shadow: the cheapest particle there is.


## A quad of [param size] metres facing the camera, drawn with a radial
## gradient from [param centre] to [param rim] (their alpha), transparent
## beyond.
static func quad(size: float, centre: float, rim: float) -> QuadMesh:
	var mesh := QuadMesh.new()
	mesh.size = Vector2(size, size)
	mesh.material = _material(_dot(centre, rim))
	return mesh


static func _material(texture: Texture2D) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	material.vertex_color_use_as_albedo = true
	material.albedo_texture = texture
	material.disable_receive_shadows = true
	return material


static func _dot(centre: float, rim: float) -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.7, 1.0])
	gradient.colors = PackedColorArray([
		Color(1.0, 1.0, 1.0, centre), Color(1.0, 1.0, 1.0, rim), Color(1.0, 1.0, 1.0, 0.0),
	])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(0.5, 0.0)
	texture.width = 32
	texture.height = 32
	return texture

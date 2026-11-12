extends RefCounted
## The fixed 3/4 camera of a model's portrait: the same angles for every
## model, backed off just far enough that the box around it fills the picture.

## From the front corner of the base, as the game's camera, but lower, to see
## a facade rather than a roof.
const YAW := 45.0
const PITCH := -28.0
const FOV := 30.0
## The share of the picture the model's box may fill.
const FILL := 0.98


## Puts [param camera] to look at the centre of [param bounds] from the portrait's
## angles, at the distance where all eight corners of the box fit.
static func frame(camera: Camera3D, bounds: AABB) -> void:
	var basis := Basis.from_euler(Vector3(deg_to_rad(PITCH), deg_to_rad(YAW), 0.0))
	camera.fov = FOV
	camera.keep_aspect = Camera3D.KEEP_WIDTH
	var centre := bounds.get_center()
	var distance := distance_for(bounds, basis)
	camera.near = maxf(distance - bounds.size.length(), 0.05)
	camera.far = distance + bounds.size.length() * 2.0
	camera.look_at_from_position(centre + basis * Vector3.BACK * distance, centre)


## How far back along [param basis]'s backward axis the camera must stand for
## the box [param bounds] to fit inside the field of view, [constant FILL].
static func distance_for(bounds: AABB, basis: Basis) -> float:
	var reach := tan(deg_to_rad(FOV) * 0.5) * FILL
	var distance := 0.0
	for corner in 8:
		var offset := bounds.get_endpoint(corner) - bounds.get_center()
		var across := maxf(absf(offset.dot(basis.x)), absf(offset.dot(basis.y)))
		distance = maxf(distance, offset.dot(basis.z) + across / reach)
	return distance

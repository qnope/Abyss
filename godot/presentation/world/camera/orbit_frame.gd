class_name OrbitFrame
## The default view fitted to the screen, without a node: how far the
## camera stands, and how high it rises along its own up, so that the
## base's outline is as wide as the screen allows, less a margin, and
## centred in the band the HUD leaves under it, whatever the screen's
## shape. The field of view spans the screen's narrow side: the width of a
## phone held upright, the height of a tablet or a desktop.

## The share of the screen's half-side left free around the base.
const MARGIN := 0.04
## Steps of the searches: each halves its interval.
const STEPS := 40


## The tangents of the half-fields, horizontal (x) and vertical (y), of a
## screen of [param aspect] (width / height) whose narrow side spans
## [param fov] degrees.
static func tangents(aspect: float, fov: float) -> Vector2:
	var half := tan(deg_to_rad(fov) / 2.0)
	return Vector2(half, half / aspect) if aspect < 1.0 else Vector2(half * aspect, half)


## The distance (x) and the rise, as a share of the distance (y), that fit
## [param points] (around the target) seen from [param yaw] and
## [param pitch] on a screen of [param aspect] whose top [param hud] share
## is covered, and its bottom [param foot] share (the bar of the tabs).
static func fit(points: PackedVector3Array, yaw: float, pitch: float, aspect: float,
		fov: float, hud: float, foot := 0.0) -> Vector2:
	var tans := tangents(aspect, fov)
	var basis := _basis(yaw, pitch)
	var near := 0.0
	for point in points:
		var across := absf(point.dot(basis.x)) / ((1.0 - MARGIN) * tans.x)
		near = maxf(near, point.dot(basis.z) + across)
	var band := Vector2(-1.0 + 2.0 * foot + MARGIN, 1.0 - 2.0 * hud - MARGIN)
	var far := near * 8.0
	var distance := near
	if _span(points, yaw, pitch, near, tans, band) > band.y - band.x:
		for step in STEPS:
			distance = (near + far) / 2.0
			if _span(points, yaw, pitch, distance, tans, band) > band.y - band.x:
				near = distance
			else:
				far = distance
		distance = far
	return Vector2(distance, _rise(points, yaw, pitch, distance, tans, band) / distance)


## The box of [param points] on the screen, from -1 to 1 on each axis, seen
## from [param distance] with the camera risen by [param rise] metres.
static func project(points: PackedVector3Array, yaw: float, pitch: float, distance: float,
		rise: float, tans: Vector2) -> Rect2:
	var basis := _basis(yaw, pitch)
	var bounds := Rect2()
	for index in points.size():
		var point := points[index]
		var depth := distance - point.dot(basis.z)
		var screen := Vector2(point.dot(basis.x) / (depth * tans.x),
			(point.dot(basis.y) - rise) / (depth * tans.y))
		bounds = Rect2(screen, Vector2.ZERO) if index == 0 else bounds.expand(screen)
	return bounds


## The height of the points on the screen once centred in [param band].
static func _span(points: PackedVector3Array, yaw: float, pitch: float, distance: float,
		tans: Vector2, band: Vector2) -> float:
	var rise := _rise(points, yaw, pitch, distance, tans, band)
	return project(points, yaw, pitch, distance, rise, tans).size.y


## How high the camera rises so that the points are centred in [param band].
static func _rise(points: PackedVector3Array, yaw: float, pitch: float, distance: float,
		tans: Vector2, band: Vector2) -> float:
	var low := -distance
	var high := distance
	for step in STEPS:
		var rise := (low + high) / 2.0
		var centre := project(points, yaw, pitch, distance, rise, tans).get_center().y
		if centre > (band.x + band.y) / 2.0:
			low = rise
		else:
			high = rise
	return (low + high) / 2.0


static func _basis(yaw: float, pitch: float) -> Basis:
	return Basis.from_euler(Vector3(deg_to_rad(pitch), deg_to_rad(yaw), 0.0))

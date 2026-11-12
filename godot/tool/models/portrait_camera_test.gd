extends TestCase
## The fixed 3/4 camera of a portrait: the same angles whatever the model, and
## backed off until the model's box just fits.

const PortraitCamera := preload("res://tool/models/portrait_camera.gd")


func _corners(bounds: AABB) -> Array[Vector3]:
	var corners: Array[Vector3] = []
	for corner in 8:
		corners.append(bounds.get_endpoint(corner))
	return corners


func _framed(bounds: AABB) -> Camera3D:
	var camera := Camera3D.new()
	add_cleanup(camera.free)
	PortraitCamera.frame(camera, bounds)
	return camera


func test_looks_at_the_centre_of_the_box_from_the_same_angles() -> void:
	for bounds: AABB in [AABB(Vector3(-1, 0, -1), Vector3(2, 3, 2)), AABB(Vector3(-5, -2, 0), Vector3(9, 1, 4))]:
		var camera := _framed(bounds)
		var forward := -camera.transform.basis.z
		var expected := (bounds.get_center() - camera.position).normalized()
		assert_true(forward.is_equal_approx(expected), "looks at the centre")
		assert_almost_eq(rad_to_deg(asin(forward.y)), PortraitCamera.PITCH, 0.01)
		assert_almost_eq(rad_to_deg(atan2(-forward.x, -forward.z)), PortraitCamera.YAW, 0.01)


func test_every_corner_of_the_box_is_in_view_and_one_touches_the_edge() -> void:
	var bounds := AABB(Vector3(-2, 0, -1), Vector3(4, 5, 2))
	var camera := _framed(bounds)
	var reach := tan(deg_to_rad(PortraitCamera.FOV) * 0.5)
	var widest := 0.0
	for corner in _corners(bounds):
		var seen := camera.transform.affine_inverse() * corner
		assert_true(seen.z < 0.0, "in front of the camera")
		var across := maxf(absf(seen.x), absf(seen.y)) / -seen.z
		assert_true(across <= reach * PortraitCamera.FILL + 0.0001, "inside the picture")
		widest = maxf(widest, across)
	assert_almost_eq(widest, reach * PortraitCamera.FILL, 0.0001)


func test_a_bigger_model_stands_further_back() -> void:
	var little := AABB(Vector3(-1, 0, -1), Vector3(2, 2, 2))
	var big := AABB(Vector3(-2, 0, -2), Vector3(4, 4, 4))
	var small := _framed(little)
	var large := _framed(big)
	var near_by := (small.position - little.get_center()).length()
	assert_almost_eq((large.position - big.get_center()).length(), near_by * 2.0, 0.01)
	assert_true(large.far > large.near)

extends TestCase
## The default view fitted to the screen: the base's outline as wide as the
## screen's narrow side allows, less a margin, centred in the band under the
## HUD, for a phone held upright, a tablet or a desktop.

## A square plateau 16 m wide with a tower in its middle.
const OUTLINE := [
	Vector3(8, 0, 8), Vector3(-8, 0, 8), Vector3(8, 0, -8), Vector3(-8, 0, -8),
	Vector3(0, 3, 0), Vector3(8, -1, 8),
]
const YAW := 45.0
const PITCH := -50.0
const FOV := 38.0


func test_fits_an_upright_phone_to_its_width_under_the_hud() -> void:
	var bounds := _fitted(390.0 / 844.0, 0.12)
	assert_almost_eq(maxf(-bounds.position.x, bounds.end.x), 1.0 - OrbitFrame.MARGIN, 1e-3,
		"as wide as the screen, less the margin")
	assert_true(bounds.position.y >= -1.0 + OrbitFrame.MARGIN - 1e-3)
	assert_true(bounds.end.y <= 1.0 - 2.0 * 0.12 - OrbitFrame.MARGIN + 1e-3)
	assert_almost_eq(bounds.get_center().y, -0.12, 1e-3, "centred under the HUD")


func test_fits_a_landscape_screen_to_its_height() -> void:
	var bounds := _fitted(16.0 / 9.0, 0.1)
	assert_true(bounds.end.x <= 1.0 - OrbitFrame.MARGIN + 1e-3)
	assert_almost_eq(bounds.size.y, 2.0 - 2.0 * 0.1 - 2.0 * OrbitFrame.MARGIN, 1e-3,
		"as tall as the band under the HUD")
	assert_almost_eq(bounds.get_center().y, -0.1, 1e-3)


func test_fits_a_square_screen_centred_without_a_hud() -> void:
	var bounds := _fitted(1.0, 0.0)
	assert_true(bounds.end.x <= 1.0 - OrbitFrame.MARGIN + 1e-3)
	assert_true(bounds.end.y <= 1.0 - OrbitFrame.MARGIN + 1e-3)
	assert_almost_eq(bounds.get_center().y, 0.0, 1e-3)


func test_the_same_field_spans_the_narrow_side() -> void:
	var half := tan(deg_to_rad(FOV) / 2.0)
	assert_eq(OrbitFrame.tangents(0.5, FOV), Vector2(half, half * 2.0))
	assert_eq(OrbitFrame.tangents(2.0, FOV), Vector2(half * 2.0, half))


func test_backs_off_as_far_as_the_screen_needs() -> void:
	var points := PackedVector3Array(OUTLINE)
	var phone := OrbitFrame.fit(points, YAW, PITCH, 390.0 / 844.0, FOV, 0.12)
	var wider := OrbitFrame.fit(points, YAW, PITCH, 390.0 / 844.0, FOV * 1.3, 0.12)
	assert_true(wider.x < phone.x, "a wider field comes closer")
	assert_true(phone.y > 0.0, "the camera rises to lower the base under the HUD")


func _fitted(aspect: float, hud: float) -> Rect2:
	var points := PackedVector3Array(OUTLINE)
	var fit := OrbitFrame.fit(points, YAW, PITCH, aspect, FOV, hud)
	return OrbitFrame.project(points, YAW, PITCH, fit.x, fit.y * fit.x,
		OrbitFrame.tangents(aspect, FOV))

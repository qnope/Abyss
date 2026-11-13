extends TestCase
## The 3D render scale a screen's density asks for: the full resolution up
## to density 2, twice the points beyond, and a viewport given it.

var _viewport: SubViewport


func before_each() -> void:
	_viewport = SubViewport.new()


func after_each() -> void:
	_viewport.free()


func test_draws_every_pixel_of_a_screen_of_density_1_or_2() -> void:
	assert_eq(RenderScale.of(1.0), 1.0)
	assert_eq(RenderScale.of(2.0), 1.0)


func test_draws_twice_the_points_of_a_denser_screen() -> void:
	assert_almost_eq(RenderScale.of(3.0), 2.0 / 3.0, 1e-6)
	assert_almost_eq(RenderScale.of(2.625), 2.0 / 2.625, 1e-6)
	assert_almost_eq(RenderScale.of(4.0), 0.5, 1e-6)


func test_never_draws_more_than_the_pixels() -> void:
	assert_eq(RenderScale.of(0.5), 1.0)
	assert_eq(RenderScale.of(0.0), 1.0, "a density the system does not know")
	assert_eq(RenderScale.of(-1.0), 1.0)


func test_caps_the_3d_of_a_viewport() -> void:
	RenderScale.apply(_viewport, 3.0)
	assert_almost_eq(_viewport.scaling_3d_scale, 2.0 / 3.0, 1e-6)
	RenderScale.apply(_viewport, 1.0)
	assert_eq(_viewport.scaling_3d_scale, 1.0)


func test_reads_the_density_of_the_screen_unless_told() -> void:
	_viewport.scaling_3d_scale = 0.25
	RenderScale.apply(_viewport)
	assert_almost_eq(_viewport.scaling_3d_scale, RenderScale.of(DisplayServer.screen_get_scale()), 1e-6)

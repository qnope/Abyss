extends TestCase
## The quality panel's choices applied to the base, the viewport and the
## idle frame cap.

var _base: BaseScene
var _viewport: SubViewport
var _idle: IdleFrameCap


func before_each() -> void:
	_base = BaseScene.new()
	_viewport = SubViewport.new()
	_idle = IdleFrameCap.new(_base.camera)


func after_each() -> void:
	_base.free()
	_viewport.free()
	_idle.free()


func test_turns_the_scene_s_effects_on_and_off() -> void:
	var settings := QualitySettings.new(_base, _viewport, _idle, false)
	settings.apply(QualityPanel.SHADOWS, false)
	settings.apply(QualityPanel.GLOW, false)
	settings.apply(QualityPanel.PARTICLES, false)
	settings.apply(QualityPanel.IDLE_CAP, false)
	assert_false(_base.key_light.shadow_enabled)
	assert_false(_base.water.environment.glow_enabled)
	assert_false(_base.snow.emitting)
	assert_false(_idle.enabled)


func test_scales_the_3d_resolution() -> void:
	var settings := QualitySettings.new(_base, _viewport, _idle, false)
	settings.apply(QualityPanel.SCALE, 0.5)
	assert_eq(_viewport.scaling_3d_scale, 0.5)


func test_keeps_an_hdr_2d_buffer_for_the_glow_of_the_compatibility_renderer() -> void:
	var settings := QualitySettings.new(_base, _viewport, _idle, true)
	assert_true(_viewport.use_hdr_2d)
	settings.apply(QualityPanel.GLOW, false)
	assert_false(_viewport.use_hdr_2d, "no glow, no need")
	settings.apply(QualityPanel.GLOW, true)
	assert_true(_viewport.use_hdr_2d)


func test_needs_no_hdr_2d_buffer_on_the_mobile_renderer() -> void:
	QualitySettings.new(_base, _viewport, _idle, false)
	assert_false(_viewport.use_hdr_2d)


func test_knows_the_renderer() -> void:
	assert_eq(QualitySettings.is_compatibility(),
		RenderingServer.get_current_rendering_method() == "gl_compatibility")

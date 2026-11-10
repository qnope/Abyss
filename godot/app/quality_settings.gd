class_name QualitySettings
extends RefCounted
## Applies the quality panel's choices to the base, the viewport and the
## idle frame cap. In the Compatibility renderer (the web's) the glow needs
## an HDR 2D buffer, twice the memory traffic of an 8-bit one: the buffer
## is on only while the glow is.

var _base: BaseScene
var _viewport: Viewport
var _idle: IdleFrameCap
var _compatibility: bool


func _init(base: BaseScene, viewport: Viewport, idle: IdleFrameCap,
		compatibility := is_compatibility()) -> void:
	_base = base
	_viewport = viewport
	_idle = idle
	_compatibility = compatibility
	_viewport.use_hdr_2d = _compatibility


## Turns [param setting] (a QualityPanel setting) to [param value].
func apply(setting: StringName, value: Variant) -> void:
	if setting == QualityPanel.SCALE:
		_viewport.scaling_3d_scale = value
		return
	var on: bool = value
	match setting:
		QualityPanel.SHADOWS:
			_base.set_shadows(on)
		QualityPanel.GLOW:
			_base.set_glow(on)
			_viewport.use_hdr_2d = _compatibility and on
		QualityPanel.PARTICLES:
			_base.set_particles(on)
		QualityPanel.IDLE_CAP:
			_idle.enabled = on


## Whether the game runs on the Compatibility renderer (OpenGL, WebGL 2).
static func is_compatibility() -> bool:
	return RenderingServer.get_current_rendering_method() == "gl_compatibility"

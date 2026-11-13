class_name QualitySettings
extends RefCounted
## Applies the quality panel's choices to the base, to the map when a bench
## measures one, to the viewport and to the idle frame cap. In the Compatibility
## renderer (the web's) the glow needs an HDR 2D buffer, twice the memory
## traffic of an 8-bit one: the buffer is on only while the glow is.
##
## The panel's render scale is a share of the scale the game draws at, the one
## the viewport had when the settings were made (RenderScale caps it on a dense
## screen): ×1 is what the player gets, never more pixels than the game draws.

var _base: BaseScene
var _map: MapScene
var _viewport: Viewport
## The 3D render scale of the game: the panel's ×1.
var _scale: float
var _idle: IdleFrameCap
var _compatibility: bool


func _init(base: BaseScene, viewport: Viewport, idle: IdleFrameCap,
		compatibility := is_compatibility(), map: MapScene = null) -> void:
	_base = base
	_map = map
	_viewport = viewport
	_scale = viewport.scaling_3d_scale
	_idle = idle
	_compatibility = compatibility
	_viewport.use_hdr_2d = _compatibility


## Turns [param setting] (a QualityPanel setting) to [param value].
func apply(setting: StringName, value: Variant) -> void:
	if setting == QualityPanel.SCALE:
		var share: float = value
		_viewport.scaling_3d_scale = _scale * share
		return
	var on: bool = value
	match setting:
		QualityPanel.SHADOWS:
			_base.set_shadows(on)
			if _map != null:
				_map.set_shadows(on)
		QualityPanel.GLOW:
			_base.set_glow(on)
			_viewport.use_hdr_2d = _compatibility and on
		QualityPanel.PARTICLES:
			_base.set_particles(on)
			if _map != null:
				_map.set_particles(on)
		QualityPanel.IDLE_CAP:
			_idle.enabled = on


## Whether the game runs on the Compatibility renderer (OpenGL, WebGL 2).
static func is_compatibility() -> bool:
	return RenderingServer.get_current_rendering_method() == "gl_compatibility"

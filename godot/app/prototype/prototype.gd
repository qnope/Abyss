extends Control
## The startup screen of the 3D prototype: the player's base, the frame
## counter and the quality panel over it, and a bench when the launch asks
## for one (BenchOptions). Every screen shows under it, so it gives its
## window the game's theme.

## The gap between the screen's safe edges and the panels, in points.
const MARGIN := 10

var idle: IdleFrameCap
var settings: QualitySettings
## The player's language, kept in user://settings.json, and the locale it
## sets on the TranslationServer (now and when the player picks another).
var language: LanguageSettings
var locale: AppLocale

@onready var base: BaseScene = $Base
@onready var counter: FrameCounter = $Hud/Top/FrameCounter
@onready var quality: QualityPanel = $Hud/Top/QualityPanel
@onready var _hud: MarginContainer = $Hud


func _enter_tree() -> void:
	get_window().theme = AbyssTheme.build()


func _ready() -> void:
	language = LanguageSettings.new()
	locale = AppLocale.new(language)
	idle = IdleFrameCap.new(base.camera)
	add_child(idle)
	settings = QualitySettings.new(base, get_viewport(), idle)
	quality.changed.connect(settings.apply)
	_fit_safe_area()
	get_viewport().size_changed.connect(_frame)
	counter.resized.connect(_frame)
	_frame()
	start_bench(BenchOptions.from_launch())


## Runs the bench [param options] ask for, if any, the frame rate uncapped.
func start_bench(options: BenchOptions) -> void:
	if options.seconds <= 0.0:
		return
	idle.enabled = false
	quality.show_value(QualityPanel.IDLE_CAP, false)
	add_child(BenchRun.new(base.camera, counter, options.seconds))


## Fits the base's default view to the screen, under the frame counter.
func _frame() -> void:
	var under := counter.get_global_rect().end.y / get_viewport_rect().size.y
	base.frame(clampf(under, 0.0, 0.5))


## Keeps the panels off the notch: the safe area's top, in points.
func _fit_safe_area() -> void:
	var safe := DisplayServer.get_display_safe_area()
	var points := get_viewport_rect().size.y / maxf(get_window().size.y, 1.0)
	var notch := roundi(safe.position.y * points) if safe.has_area() else 0
	for side: StringName in [&"margin_left", &"margin_right", &"margin_bottom"]:
		_hud.add_theme_constant_override(side, MARGIN)
	_hud.add_theme_constant_override(&"margin_top", MARGIN + notch)

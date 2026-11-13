class_name Prototype
extends Control
## The 3D prototype: the player's base, the frame counter and the quality
## panel over it, and a bench when the launch asks for one (BenchOptions),
## on the base or, with `&scene=map&level=2`, on the map of a level, which
## then takes the base's place (the base's water stays and is lit as the level).
## The app shows it instead of the menus for a bench (`?bench=1`); the scene
## capture opens it alone, so it gives its window the game's theme too.

## The gap between the screen's safe edges and the panels, in points.
const MARGIN := 10

var idle: IdleFrameCap
var settings: QualitySettings
## The map a bench on the map measures, null for any other.
var map: MapScene

## What the launch asks to bench; the app sets it before the prototype enters
## the tree, a prototype opened alone reads the launch.
var bench := BenchOptions.from_launch()

@onready var base: BaseScene = $Base
@onready var counter: FrameCounter = $Hud/Top/FrameCounter
@onready var quality: QualityPanel = $Hud/Top/QualityPanel
@onready var _hud: MarginContainer = $Hud


func _enter_tree() -> void:
	get_window().theme = AbyssTheme.build()


func _ready() -> void:
	if bench.seconds > 0.0 and bench.scene == BenchOptions.MAP:
		map = _open_map(bench.level)
	idle = IdleFrameCap.new(base.camera if map == null else map.camera)
	add_child(idle)
	settings = QualitySettings.new(base, get_viewport(), idle, QualitySettings.is_compatibility(), map)
	quality.changed.connect(settings.apply)
	_fit_safe_area()
	get_viewport().size_changed.connect(_frame)
	counter.resized.connect(_frame)
	_frame()
	start_bench(bench)


## Runs the bench [param options] ask for, if any, the frame rate uncapped.
func start_bench(options: BenchOptions) -> void:
	if options.seconds <= 0.0:
		return
	idle.enabled = false
	quality.show_value(QualityPanel.IDLE_CAP, false)
	if map == null:
		add_child(BenchRun.new(base.camera, counter, options.seconds))
		return
	add_child(BenchRun.new(map.camera, counter, options.seconds, BenchPose.pan.bind(map.camera.pan),
		"map level %d" % options.level))


## Fits the base's default view to the screen, under the frame counter.
func _frame() -> void:
	var under := counter.get_global_rect().end.y / get_viewport_rect().size.y
	base.frame(clampf(under, 0.0, 0.5))
	if map != null:
		map.frame(clampf(under, 0.0, 0.5))


## Keeps the panels off the notch.
func _fit_safe_area() -> void:
	for side: StringName in [&"margin_left", &"margin_right", &"margin_bottom"]:
		_hud.add_theme_constant_override(side, MARGIN)
	_hud.add_theme_constant_override(&"margin_top", MARGIN + SafeArea.top(get_viewport()))


## The map of [param level] in place of the base: the base is hidden and
## paused, and its water lit as the level is.
func _open_map(level: int) -> MapScene:
	var scene := MapScene.new()
	add_child(scene)
	scene.show_level(BenchGame.map_of(level))
	base.visible = false
	base.process_mode = Node.PROCESS_MODE_DISABLED
	base.water.set_mood(LightMoods.of_level(scene.level))
	scene.camera.current = true
	return scene

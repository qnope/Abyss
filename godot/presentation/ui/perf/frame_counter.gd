class_name FrameCounter
extends PanelContainer
## The frame counter over the 3D world, to measure the scene on a phone:
## the frame rate, the average and worst frame times of the last second,
## the renderer and its 3D resolution, the last frame's draw calls and
## primitives, and the summary of a bench once one has run, wrapped to fit
## a phone's width. It rewrites its lines a few times a second, not every
## frame.

## How often the lines are rewritten, in seconds.
const REFRESH := 0.25
## The width a bench's summary wraps at, in points: two or three lines, the
## counter no wider than a phone held upright leaves beside the quality panel.
const BENCH_WIDTH := 232.0

var stats := FrameStats.new(1.0)
var _since := 0.0
var _headline := _line(&"HudHeadline")
var _timing := _line(&"HudFigure")
var _load := _line(&"HudFigure")
var _renderer := _line(&"HudCaption")
var _bench := _line(&"HudFigure")


func _init() -> void:
	theme_type_variation = AbyssHudTheme.PANEL
	mouse_filter = MOUSE_FILTER_IGNORE
	var lines := VBoxContainer.new()
	lines.add_theme_constant_override(&"separation", 0)
	for label: Label in _lines():
		lines.add_child(label)
	_bench.visible = false
	_bench.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bench.custom_minimum_size.x = BENCH_WIDTH
	add_child(lines)
	# Its height is that of its figures from the start: the view fits under it.
	_headline.text = "– FPS"
	_timing.text = "– ms avg · – ms worst"
	_load.text = "– draw calls · – primitives"
	_renderer.text = "–"


func _process(delta: float) -> void:
	stats.add(delta)
	_since += delta
	if _since >= REFRESH:
		_since = 0.0
		refresh()


## Rewrites the lines from the latest figures.
func refresh() -> void:
	_headline.text = FrameReport.headline(stats)
	_timing.text = FrameReport.timing(stats)
	_load.text = FrameReport.load(
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME))
	_renderer.text = FrameReport.renderer(RenderingServer.get_current_rendering_method(),
		RenderingServer.get_current_rendering_driver_name(), get_window().size,
		get_viewport().scaling_3d_scale)


## Shows the summary of a bench, under the figures.
func show_bench(summary: String) -> void:
	_bench.text = summary
	_bench.visible = true


## The line [param index] (from 0: rate, times, load, renderer, bench).
func line(index: int) -> Label:
	return _lines()[index]


func _lines() -> Array[Label]:
	return [_headline, _timing, _load, _renderer, _bench]


static func _line(variation: StringName) -> Label:
	var label := Label.new()
	label.theme_type_variation = variation
	label.mouse_filter = MOUSE_FILTER_IGNORE
	return label

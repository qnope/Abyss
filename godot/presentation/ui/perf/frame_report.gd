class_name FrameReport
## The lines the frame counter shows, written from its figures.

## The renderers' names, by RenderingServer's rendering method.
const RENDERERS: Dictionary[String, String] = {
	"gl_compatibility": "Compatibility",
	"mobile": "Mobile",
	"forward_plus": "Forward+",
}


## The frame rate, as "59 FPS".
static func headline(stats: FrameStats) -> String:
	return "%d FPS" % roundi(stats.fps())


## The average and the worst frame times, in milliseconds.
static func timing(stats: FrameStats) -> String:
	return "%.1f ms avg · %.1f ms worst" % [stats.average_ms(), stats.worst_ms()]


## The renderer, its driver, and the 3D resolution: the window's
## [param size] in pixels times the 3D [param scale].
static func renderer(method: String, driver: String, size: Vector2i, scale: float) -> String:
	var rendered := Vector2i((Vector2(size) * scale).round())
	var line := "%s · %s · %d×%d" % [RENDERERS.get(method, method), driver, rendered.x, rendered.y]
	return line if scale == 1.0 else line + " (×%s)" % scale


## The draw calls and the primitives of the last frame.
static func load(draw_calls: int, primitives: int) -> String:
	return "%d draw calls · %s primitives" % [draw_calls, _count(primitives)]


## The summary of a bench of [param seconds]: its average frame rate and
## its 1 % low.
static func bench(stats: FrameStats, seconds: float) -> String:
	return "Bench %d s: %.1f FPS avg · %.1f FPS 1%% low" % [
		roundi(seconds), stats.fps(), stats.low_fps(0.01)
	]


static func _count(value: int) -> String:
	if value >= 1000000:
		return "%.2fM" % (value / 1e6)
	if value >= 10000:
		return "%dk" % roundi(value / 1000.0)
	return str(value)

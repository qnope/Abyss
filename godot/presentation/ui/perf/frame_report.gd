class_name FrameReport
## The lines the frame counter shows, written from its figures.

## The renderers' names, by RenderingServer's rendering method.
const RENDERERS: Dictionary[String, String] = {
	"gl_compatibility": "Compatibility",
	"mobile": "Mobile",
	"forward_plus": "Forward+",
}
## The 3D scale is written to the hundredth: a viewport keeps it as a 32-bit
## float, and the two thirds of a dense screen would read 0.66666668653488.
const SCALE_STEP := 0.01


## The frame rate, as "59 FPS".
static func headline(stats: FrameStats) -> String:
	return "%d FPS" % roundi(stats.fps())


## The average and the worst frame times, in milliseconds.
static func timing(stats: FrameStats) -> String:
	return "%.1f ms avg · %.1f ms worst" % [stats.average_ms(), stats.worst_ms()]


## The renderer, its driver, and the 3D resolution: the window's
## [param size] in pixels times the 3D [param scale], the scale named when
## the 3D is not drawn at every pixel (a dense screen, the quality panel).
static func renderer(method: String, driver: String, size: Vector2i, scale: float) -> String:
	var rendered := Vector2i((Vector2(size) * scale).round())
	var line := "%s · %s · %d×%d" % [RENDERERS.get(method, method), driver, rendered.x, rendered.y]
	return line if scale == 1.0 else line + " (×%s)" % snappedf(scale, SCALE_STEP)


## The draw calls and the primitives of the last frame.
static func load(draw_calls: int, primitives: int) -> String:
	return "%d draw calls · %s primitives" % [draw_calls, _count(primitives)]


## The summary of a bench of [param seconds] on [param subject] (the scene it
## measured: "base", "map level 2"): its average frame rate, its 1 % low, its
## worst frame and how many frames were slow, which tell one stop from a
## few frames lost over the run.
static func bench(stats: FrameStats, seconds: float, subject := "") -> String:
	var on := "" if subject.is_empty() else " on " + subject
	var slow := stats.slow_count()
	return "Bench %d s%s: %.1f FPS avg · %.1f FPS 1%% low · worst %d ms · %d slow frame%s" % [
		roundi(seconds), on, stats.fps(), stats.low_fps(0.01), roundi(stats.worst_ms()), slow,
		"" if slow == 1 else "s"
	]


## What an action of the player costs, after the summary of a bench of the
## actions: the average and the worst of [param costs], which holds the
## longest frame that followed each action.
static func action_cost(costs: FrameStats) -> String:
	return "action %d ms avg, %d worst" % [roundi(costs.average_ms()), roundi(costs.worst_ms())]


static func _count(value: int) -> String:
	if value >= 1000000:
		return "%.2fM" % (value / 1e6)
	if value >= 10000:
		return "%dk" % roundi(value / 1000.0)
	return str(value)

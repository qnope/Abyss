class_name BenchOptions
extends RefCounted
## Whether the app runs the bench at launch, and for how long: `?bench=1`
## in the web page's address (`?bench=40` for 40 seconds), or
## `-- --bench` (`--bench=40`) on the command line, so that the owner
## measures the scene the same way on each device.

## A bench's length when none is given, in seconds.
const DEFAULT_SECONDS := 20.0
## Under this, a value only turns the bench on (`?bench=1`).
const SHORTEST := 5.0

## The bench's length in seconds, 0 for none.
var seconds: float


func _init(seconds_: float) -> void:
	seconds = seconds_


## The options of this launch: the page's address on the web, the command
## line elsewhere.
static func from_launch(on_web := OS.has_feature("web")) -> BenchOptions:
	return of_query(web_query()) if on_web else of_args(OS.get_cmdline_user_args())


## The options of the query string [param query] (`?bench=1&...`).
static func of_query(query: String) -> BenchOptions:
	for pair in query.trim_prefix("?").split("&", false):
		var parts := pair.split("=")
		if parts[0] == "bench":
			return _of_value(parts[1] if parts.size() > 1 else "1")
	return BenchOptions.new(0.0)


## The options of the command line's user arguments (after `--`).
static func of_args(args: PackedStringArray) -> BenchOptions:
	for arg in args:
		if arg == "--bench" or arg.begins_with("--bench="):
			return _of_value(arg.get_slice("=", 1) if arg.contains("=") else "1")
	return BenchOptions.new(0.0)


## The page's query string, read through the browser; empty off the web,
## where JavaScriptBridge answers nothing.
static func web_query() -> String:
	var search: Variant = JavaScriptBridge.eval("window.location.search", true)
	return search if search is String else ""


static func _of_value(value: String) -> BenchOptions:
	var number := value.to_float()
	if number >= SHORTEST:
		return BenchOptions.new(number)
	return BenchOptions.new(DEFAULT_SECONDS if number > 0.0 else 0.0)

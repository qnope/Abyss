class_name BenchOptions
extends RefCounted
## Whether the app runs the bench at launch, how long, and on which scene:
## `?bench=1` in the web page's address (`?bench=40` for 40 seconds), then
## `&scene=map&level=2` for the map of the second level (the base by default),
## or `-- --bench --bench-scene=map --bench-level=2` on the command line, so
## that the owner measures each scene the same way on each device.

## A bench's length when none is given, in seconds.
const DEFAULT_SECONDS := 20.0
## Under this, a value only turns the bench on (`?bench=1`).
const SHORTEST := 5.0
## The scenes a bench measures.
const BASE := &"base"
const MAP := &"map"

## The bench's length in seconds, 0 for none.
var seconds: float
## What it measures: [constant BASE] or [constant MAP].
var scene: StringName
## The level of the map it measures, from 1.
var level: int


func _init(seconds_: float, scene_ := BASE, level_ := 1) -> void:
	seconds = seconds_
	scene = scene_
	level = level_


## The options of this launch: the page's address on the web, the command
## line elsewhere.
static func from_launch(on_web := OS.has_feature("web")) -> BenchOptions:
	return of_query(web_query()) if on_web else of_args(OS.get_cmdline_user_args())


## The options of the query string [param query] (`?bench=1&scene=map...`).
static func of_query(query: String) -> BenchOptions:
	var pairs: Dictionary[String, String] = {}
	for pair in query.trim_prefix("?").split("&", false):
		pairs[pair.get_slice("=", 0)] = pair.get_slice("=", 1) if pair.contains("=") else "1"
	return _of_pairs(pairs, "")


## The options of the command line's user arguments (after `--`).
static func of_args(args: PackedStringArray) -> BenchOptions:
	var pairs: Dictionary[String, String] = {}
	for arg in args:
		if arg.begins_with("--"):
			pairs[arg.get_slice("=", 0).trim_prefix("--")] = arg.get_slice("=", 1) if arg.contains("=") else "1"
	return _of_pairs(pairs, "bench-")


## The page's query string, read through the browser; empty off the web,
## where JavaScriptBridge answers nothing.
static func web_query() -> String:
	var search: Variant = JavaScriptBridge.eval("window.location.search", true)
	return search if search is String else ""


static func _of_pairs(pairs: Dictionary[String, String], prefix: String) -> BenchOptions:
	if not pairs.has("bench"):
		return BenchOptions.new(0.0)
	var number := pairs["bench"].to_float()
	var seconds_ := number if number >= SHORTEST else (DEFAULT_SECONDS if number > 0.0 else 0.0)
	var scene_name: String = pairs.get(prefix + "scene", "")
	var level_text: String = pairs.get(prefix + "level", "1")
	return BenchOptions.new(seconds_, MAP if scene_name == "map" else BASE, maxi(level_text.to_int(), 1))

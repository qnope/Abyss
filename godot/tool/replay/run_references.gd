extends SceneTree
## Replays the games of `reference/games/` and compares them with Dart's,
## outside the unit tests (they take minutes):
##
##     godot --headless --path godot --script res://tool/replay/run_references.gd -- [game ...]
##
## A game is named by its file name without `.json`, a long case by its
## name in LongCases; none plays them all, `--list` lists them, the longest
## first. Prints a line per game, its turns, time and result, then what
## differs (ReferenceReplay.differences), and exits with 1 when anything
## differs or a name is unknown, 0 otherwise. `tool/godot_reference.sh`
## runs them in parallel processes.


func _init() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var names := OS.get_cmdline_user_args()
	if names == PackedStringArray(["--list"]):
		print("\n".join(ReferenceRun.every_name()))
		quit(0)
		return
	if names.is_empty():
		names = ReferenceRun.every_name()
	var failed := 0
	for game_name: String in names:
		if not ReferenceRun.new(game_name).passed:
			failed += 1
	if names.size() > 1:
		print("%d games, %d failed" % [names.size(), failed])
	quit(1 if failed > 0 else 0)

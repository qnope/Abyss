extends SceneTree
## Plays scripted games headless with the Godot port, as `bin/simulate.dart`
## does with the Dart rules, and prints the same text (tool/simulate/
## README.md):
##
##     tool/godot_simulate.sh --strategy balanced --games 100
##     godot --headless --path godot --script res://tool/simulate/simulate.gd -- [option ...]
##
## The options are Dart's. `ABYSS_CWD` names the folder `--scenario` and
## `--replay` are read from (the repository by default: Godot works in the
## project's folder); `ABYSS_SIMULATE_OUT` a file to write the text to,
## instead of the standard output, which Godot starts with its banner.
## Exits with 1, the error on the standard error, where Dart throws.


func _init() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var cwd := OS.get_environment("ABYSS_CWD")
	var simulation := Simulation.new(OS.get_cmdline_user_args(), cwd if not cwd.is_empty() else ReferenceFiles.repo_root())
	if not simulation.error.is_empty():
		printerr(simulation.error)
		quit(1)
		return
	var out := OS.get_environment("ABYSS_SIMULATE_OUT")
	if out.is_empty():
		printraw(simulation.output)
	else:
		var file := FileAccess.open(out, FileAccess.WRITE)
		file.store_string(simulation.output)
		file.close()
	quit(0)

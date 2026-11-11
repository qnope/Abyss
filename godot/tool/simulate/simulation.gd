class_name Simulation
extends RefCounted
## What `dart run bin/simulate.dart <args>` prints, played by the Godot
## port: the same games, the same text, to the byte (tool/simulate/README.md).
##
## `--scenario` and `--replay` name files from `cwd`, or are absolute; the
## human plans (`--strategy plan85`...) are read from the repository.
## `--workers` is read and left out: Godot plays the games one after the
## other (GameWorkers), and the batch is the same.

var options: SimulateOptions
## What went wrong where Dart throws (an unknown strategy, a file that
## cannot be read, a bad number), "" when the batch was played.
var error := ""
## The text printed, each line ended by a line feed, as `stdout.writeln`.
var output := ""

var _build: Callable


func _init(args: PackedStringArray, cwd: String) -> void:
	options = SimulateOptions.new(args)
	PlanLibrary.use_reader(ReferenceFiles.text_of)
	_build = _builder(cwd)
	var runner := ScriptRunner.new(options.whole("turns", 60), options.difficulty())
	options.whole("workers", 1)
	var games := options.whole("games", 20)
	var first_seed := options.whole("seed", 1)
	if error.is_empty():
		error = options.error
	if error.is_empty() and _build.call(first_seed) == null:
		error = "no script to play: see the errors above"
	if not error.is_empty():
		return
	var report := BatchRunner.new(runner).run(_build, games, first_seed)
	var script: GameScript = _build.call(first_seed)
	output = "\n".join(_json(report) if options.has("json") else _text(script.name(), report)) + "\n"


## `GameScript Function(int seed)`; its scripts are null where Dart throws.
func _builder(cwd: String) -> Callable:
	if options.has("replay"):
		var source := _read(options.text("replay", ""), cwd)
		var variant := options.variant()
		return func(seed_: int) -> GameScript:
			return PlanScript.from_replay(source, variant, DartRandom.new(seed_, false))
	if options.has("scenario"):
		var scenario := _read(options.text("scenario", ""), cwd)
		return func(_seed: int) -> GameScript: return ScenarioParser.parse(scenario)
	var strategy := options.text("strategy", "balanced")
	return func(_seed: int) -> GameScript: return ScriptLibrary.by_name(strategy)


func _read(path: String, cwd: String) -> String:
	var full := path if path.is_absolute_path() else cwd.path_join(path)
	if not FileAccess.file_exists(full):
		error = "Cannot open file, path = '%s'" % path
		return "{}"
	return FileAccess.get_file_as_string(full)


func _json(report: BatchReport) -> PackedStringArray:
	var runs := report.runs.map(func(r: ScriptRunReport) -> Dictionary: return r.to_json())
	return [DartJson.encode({"summary": report.to_json(), "runs": runs}, "  ")]


func _text(name: String, report: BatchReport) -> PackedStringArray:
	var lines := PackedStringArray()
	if options.has("verbose"):
		for run: ScriptRunReport in report.runs:
			lines.append("seed %d: %s au tour %d, raids %d repoussés / %d perdus, bruit %d" % [
				run.run_seed, DartEnum.name_of(GameStatus.Value, run.status), run.turns_played,
				run.raids_repelled(), run.raids_lost(), run.total_noise,
			])
		if not report.runs.is_empty():
			lines.append("\nJournal de la partie seed %d :" % report.runs[0].run_seed)
			for entry: ScriptLogEntry in report.runs[0].log:
				lines.append(str(entry))
			lines.append("")
	lines.append_array(BatchSummary.lines_of(name, report))
	return lines

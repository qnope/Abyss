class_name ReferenceRun
extends RefCounted
## One game of `reference/games/` replayed by `run_references.gd`, or one of
## its LongCases: prints `<name>: <turns> turns, <ms> ms, ok` (no turns for a
## case) or `FAILED` and each difference.

var passed := false


func _init(name: String) -> void:
	var start := Time.get_ticks_msec()
	var found := PackedStringArray()
	var turns := ""
	if name in LongCases.names():
		found = LongCases.run(name)
	else:
		var committed := CommittedGame.named(name)
		if committed == null:
			print("%s: FAILED, no such game in reference/games/ nor long case" % name)
			return
		var replay := ReferenceReplay.new(committed)
		found = replay.differences()
		turns = "%d turns, " % replay.recorder.turns.size()
	passed = found.is_empty()
	print("%s: %s%d ms, %s" % [name, turns, Time.get_ticks_msec() - start, "ok" if passed else "FAILED"])
	for difference: String in found:
		print("  " + difference)


## The reference games, the biggest file (the longest game) first, and the
## long cases (up to 95 s) right after it.
static func every_name() -> PackedStringArray:
	var games := CommittedGame.all()
	games.sort_custom(func(a: CommittedGame, b: CommittedGame) -> bool:
		return a.text_length > b.text_length or (a.text_length == b.text_length and a.name < b.name))
	var names := PackedStringArray()
	for game: CommittedGame in games:
		names.append(game.name)
	var cases := LongCases.names()
	for i: int in cases.size():
		names.insert(1 + i, cases[i])
	return names

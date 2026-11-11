class_name SaveRoundTrip
extends RefCounted
## A reference game replayed (ReferenceReplay) with its save checked as its
## turns start (SaveCheckRecorder): every loaded game must be the game that
## was saved, and a game loaded from the save of a turn of `resumed` must
## play on as the game that was never saved, every following turn, its end
## and its journal.

var replay: ReferenceReplay
var checker: SaveCheckRecorder
## The number of turns played on from a loaded game.
var resumed_turns := 0


func _init(committed: CommittedGame, every := 1, resumed: Array[int] = []) -> void:
	checker = SaveCheckRecorder.new(every, resumed)
	replay = ReferenceReplay.new(committed, checker)


## What went wrong, one line each, empty when nothing did: what the replay
## found against the file, what the saves found, then each game played on.
func problems() -> PackedStringArray:
	var found := replay.differences()
	found.append_array(checker.problems)
	for turn: int in checker.saves:
		found.append_array(_resume(turn, checker.saves[turn]))
	return found


func _resume(turn: int, text: String) -> PackedStringArray:
	var found := PackedStringArray()
	var game := SaveCodec.from_text(text).game
	var recorder := ReferenceRecorder.new(Sha256Hex.of)
	replay.runner(recorder).run_on(game, replay.script(), DartRandom.new(replay.seed_of(), false), replay.seed_of())
	var first := 0
	while checker.turns[first].turn != turn:
		first += 1
	var expected: Array[ReplayComparison.Turn] = []
	expected.assign(checker.turns.slice(first))
	resumed_turns += recorder.turns.size()
	if recorder.turns.size() != expected.size():
		found.append("from turn %d: %d turns played on, %d without the save" % [
			turn, recorder.turns.size(), expected.size()])
	for i: int in mini(recorder.turns.size(), expected.size()):
		var sections := ReplayComparison.differing(expected[i].digests, recorder.turns[i].digests)
		if recorder.turns[i].turn != expected[i].turn or not sections.is_empty():
			found.append("from turn %d: turn %d started as turn %d, differing in: %s" % [
				turn, expected[i].turn, recorder.turns[i].turn, ", ".join(sections)])
			break
	var last := ReplayComparison.differing(replay.final_digests, GameSnapshot.digests(game, Sha256Hex.of))
	if not last.is_empty():
		found.append("from turn %d: when it stopped, differing in: %s" % [turn, ", ".join(last)])
	if JSON.stringify(ReplayExport.to_json(game)) != JSON.stringify(ReplayExport.to_json(replay.game)):
		found.append("from turn %d: another journal" % turn)
	return found

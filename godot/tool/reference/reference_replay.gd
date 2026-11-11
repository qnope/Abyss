class_name ReferenceReplay
extends RefCounted
## The replay half of ReferenceExporter.export
## (lib/domain/reference/reference_exporter.dart): the journal of a
## committed game, read by ScenarioParser and played by ScriptRunner with
## the human id, the turn limit, the difficulty and the seed of its source,
## through a ReferenceRecorder (reference/README.md, "Replaying it").
## `differences()` compares what it went through with the file.

var committed: CommittedGame
var recorder := ReferenceRecorder.new(Sha256Hex.of)
var report: ScriptRunReport
var game: Game
## The digests when the game stopped.
var final_digests: PackedStringArray


func _init(committed_: CommittedGame) -> void:
	committed = committed_
	var source := committed.source()
	var difficulty_name: String = source["difficulty"]
	var difficulty: Difficulty.Value = DartEnum.by_name(Difficulty.Value, difficulty_name)
	var turns: int = source["turns"]
	var seed_: int = source["seed"]
	var runner := ScriptRunner.new(turns, difficulty, CommittedGame.HUMAN_ID, recorder)
	var journal: Dictionary = ReplayJournal.whole_numbers(committed.journal())
	# jsonEncode keeps the order of every map: an army is played in its order.
	report = runner.run(ScenarioParser.parse(JSON.stringify(journal, "", false)), seed_)
	game = recorder.game()
	final_digests = GameSnapshot.digests(game, Sha256Hex.of)


## What differs from the file (or from `file`, another one), one line each,
## empty when nothing does: the first turn that started differently and
## its sections, the number of turns, the final digests, the result, the
## journal and the coverage.
func differences(file: CommittedGame = null) -> PackedStringArray:
	var filed := file if file != null else committed
	var found := PackedStringArray()
	var played := filed.played_turns()
	for i: int in mini(played.size(), recorder.turns.size()):
		var replayed := recorder.turns[i]
		var sections := ReplayComparison.differing(played[i].digests, replayed.digests)
		if replayed.turn != played[i].turn or not sections.is_empty():
			found.append("turn %d started as turn %d, differing in: %s" % [
				played[i].turn, replayed.turn, ", ".join(sections)])
			break
	if played.size() != recorder.turns.size():
		found.append("%d turns started, %d in the file" % [recorder.turns.size(), played.size()])
	var last := ReplayComparison.differing(filed.final_digests(), final_digests)
	if not last.is_empty():
		found.append("when it stopped, differing in: " + ", ".join(last))
	var result := [DartEnum.name_of(GameStatus.Value, game.status), game.turn]
	_compare(found, "result", result, [filed.status(), filed.turn()])
	_compare(found, "journal", ReplayExport.to_json(game), ReplayJournal.whole_numbers(filed.journal()))
	var coverage := filed.coverage()
	_compare(found, "actions", ReferenceReplay._by_name(ActionType.Value, recorder.actions), coverage["actions"])
	_compare(found, "events", ReferenceReplay._by_name(RandomEventType.Value, recorder.events), coverage["events"])
	_compare(found, "milestones", ReferenceMilestones.of(game, report.milestones), coverage["milestones"])
	return found


static func _compare(found: PackedStringArray, what: String, replayed: Variant, filed: Variant) -> void:
	var text := JSON.stringify(replayed, "", false)
	if text != JSON.stringify(filed, "", false):
		found.append("%s: %s" % [what, text.left(300)])


## The counts of `counted`, keyed by the Dart names of `type`, in its order.
static func _by_name(type: Dictionary, counted: Dictionary) -> Dictionary:
	var named := {}
	for value: int in type.values():
		if counted.has(value):
			named[DartEnum.name_of(type, value)] = counted[value]
	return named

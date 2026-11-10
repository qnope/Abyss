class_name ScriptLogEntry
extends RefCounted
## lib/domain/script/script_log_entry.dart: one action a script tried, kept
## to replay or debug a game.

var turn: int
var description: String
var success: bool
## Why the action failed, if it did (an ActionFailure.Value); null otherwise.
var reason: Variant


func _init(turn_: int, description_: String, success_: bool, reason_: Variant = null) -> void:
	turn = turn_
	description = description_
	success = success_
	reason = reason_


## Dart's `toString`; a failure without reason writes `null`, as Dart does.
func _to_string() -> String:
	if success:
		return "T%d ✓ %s" % [turn, description]
	if reason == null:
		return "T%d ✗ %s (null)" % [turn, description]
	var why: ActionFailure.Value = reason
	return "T%d ✗ %s (%s)" % [turn, description, DartEnum.name_of(ActionFailure.Value, why)]

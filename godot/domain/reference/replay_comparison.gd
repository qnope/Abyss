class_name ReplayComparison
extends RefCounted
## lib/domain/reference/replay_comparison.dart: checks that the replay of a
## journal went through the same states as the game the journal comes
## from, and says where it did not. Where Dart throws a StateError, the
## port logs it as an error and answers false.


## `TurnDigests` of reference_recorder.dart, a record: the digests of every
## section of a game at the start of `turn`.
class Turn:
	extends RefCounted
	var turn: int
	var digests: PackedStringArray

	func _init(turn_: int, digests_: PackedStringArray) -> void:
		turn = turn_
		digests = digests_


## Logs an error naming the sections whose digests differ.
static func same(when: String, played: PackedStringArray, replayed: PackedStringArray) -> bool:
	var found := differing(played, replayed)
	if not found.is_empty():
		push_error("The replay differs %s: %s" % [when, ", ".join(found)])
	return found.is_empty()


## Not in the Dart class: the sections whose digests differ, which `same`
## names.
static func differing(played: PackedStringArray, replayed: PackedStringArray) -> PackedStringArray:
	var names := SnapshotSections.names()
	var found := PackedStringArray()
	for i: int in played.size():
		if played[i] != replayed[i]:
			found.append(names[i])
	return found


## Logs an error on the first turn that started differently.
static func same_turns(played: Array[Turn], replayed: Array[Turn]) -> bool:
	if played.size() != replayed.size():
		push_error("The replay differs: %d turns started, %d in the game" % [replayed.size(), played.size()])
		return false
	for i: int in played.size():
		if not same("at the start of turn %d" % played[i].turn, played[i].digests, replayed[i].digests):
			return false
	return true

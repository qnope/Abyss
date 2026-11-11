class_name CaseChecks
extends RefCounted
## What a long case of `LongCases` found wrong: each `expect` that does not
## hold adds its line, as a failed `expect` of a Dart test would.

var failures := PackedStringArray()


func expect(holds: bool, what: String) -> void:
	if not holds:
		failures.append(what)

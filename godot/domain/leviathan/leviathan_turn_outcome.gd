class_name LeviathanTurnOutcome
extends RefCounted
## `LeviathanTurnOutcome` of lib/domain/leviathan/leviathan_resolver.dart:
## what the guardians did while a turn ended.

## Their attack on the Faille fought this turn, if any.
var report: FactionAttackReport
## Their attack announced this turn; it strikes at the end of the next.
var announced: LeviathanAnnouncement


func _init(report_: FactionAttackReport = null, announced_: LeviathanAnnouncement = null) -> void:
	report = report_
	announced = announced_

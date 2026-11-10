class_name VolcanoTurnOutcome
extends RefCounted
## lib/domain/volcano/volcano_resolver.dart, `VolcanoTurnOutcome`: what the
## volcano did while a turn ended.

## The wave fought on the kernel this turn, if any.
var report: VolcanoReport
## Wave announced this turn; it hits at the end of the next one.
var announced: MonsterLair


func _init(report_: VolcanoReport = null, announced_: MonsterLair = null) -> void:
	report = report_
	announced = announced_

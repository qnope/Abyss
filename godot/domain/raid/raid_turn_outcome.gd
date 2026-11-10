class_name RaidTurnOutcome
extends RefCounted
## lib/domain/raid/raid_resolver.dart, `RaidTurnOutcome`: what the raid
## system did while a turn ended.

## The raid fought this turn, if any.
var report: RaidReport
## Wave announced this turn, if any; it hits at `announced_turn`.
var announced: MonsterLair
## An int, or null when no wave was announced.
var announced_turn: Variant


func _init(report_: RaidReport = null, announced_: MonsterLair = null, announced_turn_: Variant = null) -> void:
	report = report_
	announced = announced_
	announced_turn = announced_turn_

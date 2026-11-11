class_name TurnResult
extends RefCounted
## lib/domain/turn/turn_result.dart, its type TurnResult: what the end of a
## turn did, as the human reads it. A turn result is never saved. The type
## TurnResourceChange of the same Dart file is `turn_resource_change.gd`.

var changes: Array[TurnResourceChange]
var previous_turn: int
var new_turn: int
var had_recruited_units: bool
var deactivated_buildings: Array[BuildingType.Value]
var lost_units: Dictionary[UnitType.Value, int]
var explorations: Array[ExplorationResult]
var arrived_reinforcements: Array[ReinforcementOrder]
## Raid fought on the base at the end of this turn, if any.
var raid: RaidReport
## Raid announced at the end of this turn, if any; it hits the base at the
## end of `announced_raid_turn` (an int, or null).
var announced_raid: MonsterLair
var announced_raid_turn: Variant
## Kraken wave fought on the kernel at the end of this turn, if any.
var volcano: VolcanoReport
## Kraken wave announced at the end of this turn; it hits the kernel at the
## end of the next one.
var announced_wave: MonsterLair
## Random event drawn at the end of this turn (a RandomEventType.Value), if
## any; one with a choice waits for it during the next turn.
var event: Variant
## Event left without a choice this turn (a RandomEventType.Value or null),
## settled with its prudent option.
var defaulted_event: Variant
## School of predators faced this turn and fought at its end, if any.
var predators: RaidReport
## Objectives completed at the end of this turn, in catalog order, with the
## rewards they credited.
var objectives: Array[ObjectiveCompletion]
## Temporary objectives of the events that ended this turn, done or missed.
var temporary_objectives: Array[TemporaryObjectiveEnd]
## Attacks of factions on the human this turn: those on its posts and its
## kernel, fought while the factions played, then those on the base fought
## at its end, in the order they were announced.
var attacks: Array[FactionAttackReport]
## The guardians' attack on the human's first Faille fought at the end of
## this turn, if any; also the last of `attacks`.
var leviathan: FactionAttackReport
## The guardians' attack announced at the end of this turn; it strikes at
## the end of the next one.
var announced_leviathan: LeviathanAnnouncement


func _init(
	changes_: Array[TurnResourceChange],
	previous_turn_: int,
	new_turn_: int,
	had_recruited_units_: bool,
	deactivated_buildings_: Array[BuildingType.Value] = [],
	lost_units_: Dictionary[UnitType.Value, int] = {},
	explorations_: Array[ExplorationResult] = [],
	arrived_reinforcements_: Array[ReinforcementOrder] = [],
	raid_: RaidReport = null,
	announced_raid_: MonsterLair = null,
	announced_raid_turn_: Variant = null,
	volcano_: VolcanoReport = null,
	announced_wave_: MonsterLair = null,
	event_: Variant = null,
	defaulted_event_: Variant = null,
	predators_: RaidReport = null,
	objectives_: Array[ObjectiveCompletion] = [],
	temporary_objectives_: Array[TemporaryObjectiveEnd] = [],
	attacks_: Array[FactionAttackReport] = [],
	leviathan_: FactionAttackReport = null,
	announced_leviathan_: LeviathanAnnouncement = null,
) -> void:
	changes = changes_
	previous_turn = previous_turn_
	new_turn = new_turn_
	had_recruited_units = had_recruited_units_
	deactivated_buildings = deactivated_buildings_
	lost_units = lost_units_
	explorations = explorations_
	arrived_reinforcements = arrived_reinforcements_
	raid = raid_
	announced_raid = announced_raid_
	announced_raid_turn = announced_raid_turn_
	volcano = volcano_
	announced_wave = announced_wave_
	event = event_
	defaulted_event = defaulted_event_
	predators = predators_
	objectives = objectives_
	temporary_objectives = temporary_objectives_
	attacks = attacks_
	leviathan = leviathan_
	announced_leviathan = announced_leviathan_
